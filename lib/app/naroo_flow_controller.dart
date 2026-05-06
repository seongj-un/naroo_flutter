import 'package:flutter/foundation.dart';

import '../api/api_types.dart';
import '../domain/diagnostic_models.dart';
import '../domain/learning_models.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/diagnostic_repository.dart';
import '../domain/repositories/learning_repository.dart';
import '../domain/repositories/recovery_repository.dart';
import '../ui/screens/auth_screens.dart';

enum NarooStage {
  entry,
  auth,
  emailVerification,
  home,
  startingPoint,
  diagnostic,
  result,
  recoveryMission,
  missionFeedback,
  savedProgress,
}

class NarooFlowController extends ChangeNotifier {
  NarooFlowController({
    required this.authRepository,
    required this.learningRepository,
    required this.diagnosticRepository,
    required this.recoveryRepository,
  });

  final AuthRepository authRepository;
  final LearningRepository learningRepository;
  final DiagnosticRepository diagnosticRepository;
  final RecoveryRepository recoveryRepository;

  NarooStage stage = NarooStage.entry;
  AuthMode authMode = AuthMode.signup;
  String nickname = '나루';
  String email = '';
  String? startingPoint;
  String? diagnosticSessionId;
  int currentQuestionIndex = 0;
  final Map<String, DiagnosticAnswer> diagnosticAnswers = {};
  List<DiagnosticQuestion> _diagnosticQuestions = [];
  DiagnosticResult? diagnosticResult;
  RecoveryMission? activeRecoveryMission;
  RecoverySubmissionFeedback? recoveryFeedback;
  bool missionCompleted = false;
  bool emailVerified = false;
  bool isAuthBusy = false;
  bool isFlowBusy = false;
  String? authErrorMessage;
  String? flowErrorMessage;

  List<String> get mathStatusOptions => learningRepository.mathStatusOptions;

  List<String> get startingPointOptions =>
      learningRepository.startingPointOptions;

  List<DiagnosticQuestion> get diagnosticQuestions =>
      _diagnosticQuestions.isEmpty
      ? diagnosticRepository.questions
      : _diagnosticQuestions;

  List<WeakLink> get weakLinks {
    final result = diagnosticResult;
    if (result == null) {
      return diagnosticRepository.weakLinks;
    }
    return result.weakLinks.isEmpty
        ? [WeakLink(title: result.primaryRecoveryConcept, body: result.summary)]
        : result.weakLinks
              .map((link) => WeakLink(title: link, body: result.summary))
              .toList(growable: false);
  }

  RecoveryMission get recoveryMission =>
      activeRecoveryMission ?? recoveryRepository.firstMission;

  String get savedProgressNextAction =>
      recoveryRepository.nextAction(missionCompleted: missionCompleted);

  DiagnosticQuestion get currentQuestion =>
      diagnosticQuestions[currentQuestionIndex];

  bool get hasDiagnosticResult =>
      diagnosticResult != null ||
      diagnosticAnswers.length == diagnosticQuestions.length;

  void openAuth(AuthMode mode) {
    authMode = mode;
    stage = NarooStage.auth;
    notifyListeners();
  }

  void updateAuthMode(AuthMode mode) {
    authMode = mode;
    notifyListeners();
  }

  void goToEntry() {
    stage = NarooStage.entry;
    notifyListeners();
  }

  Future<void> submitSignup({
    required String loginId,
    required String email,
    required String password,
    required String nickname,
    required String mathStatus,
  }) {
    return _runAuthAction(() async {
      final profile = await authRepository.signUp(
        loginId: loginId,
        email: email,
        password: password,
        nickname: nickname,
        mathStatus: mathStatus,
      );
      this.nickname = profile.nickname;
      this.email = profile.email;
      emailVerified = profile.emailVerified;
      stage = NarooStage.emailVerification;
    });
  }

  Future<void> submitLogin({
    required String loginId,
    required String password,
  }) {
    return _runAuthAction(() async {
      final profile = await authRepository.login(
        loginId: loginId,
        password: password,
      );
      nickname = profile.nickname;
      email = profile.email;
      emailVerified = profile.emailVerified;
      await _loadLearningHome();
    });
  }

  Future<void> completeVerification(String token) {
    return _runAuthAction(() async {
      final profile = await authRepository.verifyEmail(
        token: token,
        nickname: nickname,
        email: email,
      );
      nickname = profile.nickname;
      email = profile.email;
      emailVerified = profile.emailVerified;
      await _loadLearningHome();
    });
  }

  void skipVerificationForNow() {
    stage = NarooStage.home;
    notifyListeners();
  }

  void goToEmailVerification() {
    stage = NarooStage.emailVerification;
    notifyListeners();
  }

  void goToStartingPoint() {
    stage = NarooStage.startingPoint;
    notifyListeners();
  }

  Future<void> goHome() {
    return _runFlowAction(() async {
      await _loadLearningHome();
    });
  }

  Future<void> startDiagnostic(String startingPoint) {
    return _runFlowAction(() async {
      this.startingPoint = startingPoint;
      currentQuestionIndex = 0;
      diagnosticAnswers.clear();
      diagnosticResult = null;
      activeRecoveryMission = null;
      recoveryFeedback = null;
      missionCompleted = false;

      await diagnosticRepository.selectStartingPoint(startingPoint);
      final session = await diagnosticRepository.createSession();
      diagnosticSessionId = session.id;
      _diagnosticQuestions = await diagnosticRepository.getQuestions(
        session.id,
      );
      if (_diagnosticQuestions.isEmpty) {
        throw StateError('Diagnostic questions are empty.');
      }
      stage = NarooStage.diagnostic;
    });
  }

  void backToStartingPoint() {
    stage = NarooStage.startingPoint;
    notifyListeners();
  }

  Future<void> submitDiagnosticAnswer(
    DiagnosticQuestion question,
    String? answerId,
  ) async {
    diagnosticAnswers[question.id] = answerId == null
        ? const DiagnosticAnswer.unknown()
        : DiagnosticAnswer.selected(answerId);

    if (currentQuestionIndex == diagnosticQuestions.length - 1) {
      await _runFlowAction(() async {
        final sessionId = diagnosticSessionId;
        if (sessionId == null) {
          throw StateError('Diagnostic session is missing.');
        }
        diagnosticResult = await diagnosticRepository.submitAnswers(
          diagnosticSessionId: sessionId,
          answers: diagnosticAnswers,
        );
        stage = NarooStage.result;
      });
    } else {
      currentQuestionIndex += 1;
      notifyListeners();
    }
  }

  void goToResult() {
    stage = NarooStage.result;
    notifyListeners();
  }

  Future<void> startRecoveryMission() {
    return _runFlowAction(() async {
      final sessionId = diagnosticResult?.diagnosticSessionId;
      if (sessionId == null || sessionId.isEmpty) {
        throw StateError('Diagnostic result is missing.');
      }
      activeRecoveryMission = await recoveryRepository.createMission(
        diagnosticSessionId: sessionId,
      );
      stage = NarooStage.recoveryMission;
    });
  }

  Future<void> completeRecoveryMission(String answerText) {
    return _runFlowAction(() async {
      final mission = activeRecoveryMission ?? recoveryRepository.firstMission;
      recoveryFeedback = await recoveryRepository.submitMission(
        recoveryMissionId: mission.id,
        answerText: answerText,
      );
      activeRecoveryMission = recoveryFeedback?.mission ?? mission;
      missionCompleted = true;
      stage = NarooStage.missionFeedback;
    });
  }

  void goToSavedProgress() {
    stage = NarooStage.savedProgress;
    notifyListeners();
  }

  void continueSavedProgress() {
    stage = missionCompleted ? NarooStage.home : NarooStage.recoveryMission;
    notifyListeners();
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    isAuthBusy = true;
    authErrorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      authErrorMessage = _authFailureMessage(error);
    } finally {
      isAuthBusy = false;
      notifyListeners();
    }
  }

  Future<void> _runFlowAction(Future<void> Function() action) async {
    isFlowBusy = true;
    flowErrorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      flowErrorMessage = _flowFailureMessage(error);
    } finally {
      isFlowBusy = false;
      notifyListeners();
    }
  }

  Future<void> _loadLearningHome() async {
    final home = await learningRepository.getLearningHome();
    nickname = home.nickname;
    emailVerified = home.emailVerified;
    activeRecoveryMission = home.todayMission;

    final latestDiagnostic = home.latestDiagnostic;
    if (latestDiagnostic != null) {
      diagnosticSessionId = latestDiagnostic.diagnosticSessionId;
      diagnosticResult = DiagnosticResult(
        diagnosticSessionId: latestDiagnostic.diagnosticSessionId,
        mathArea: latestDiagnostic.mathArea,
        status: latestDiagnostic.status,
        totalQuestionCount: latestDiagnostic.totalQuestionCount,
        correctCount: latestDiagnostic.correctCount,
        wrongCount: latestDiagnostic.wrongCount,
        unknownCount: latestDiagnostic.unknownCount,
        weakLinks: latestDiagnostic.weakLinks,
        primaryRecoveryConcept: latestDiagnostic.primaryRecoveryConcept,
        summary: latestDiagnostic.summary,
      );
    }

    missionCompleted = home.todayMission?.status == 'COMPLETED';
    stage = NarooStage.home;
  }

  String _authFailureMessage(Object error) {
    if (error is ApiError) {
      return switch (error.errorCode) {
        'AUTH_INVALID_CREDENTIALS' => '아이디나 비밀번호가 맞지 않아요.',
        'AUTH_ACCESS_TOKEN_MISSING' ||
        'GLOBAL_UNAUTHORIZED' => '로그인이 만료됐어요. 다시 로그인해 주세요.',
        'GLOBAL_VALIDATION_ERROR' => '입력한 정보를 다시 확인해 주세요.',
        _ => '기록을 불러오지 못했어요. 잠시 뒤 다시 시도해 주세요.',
      };
    }

    if (_looksLikeNetworkError(error)) {
      return '서버에 연결하지 못했어요. 네트워크와 API 주소를 확인해 주세요.';
    }

    return '기록을 불러오지 못했어요. 잠시 뒤 다시 시도해 주세요.';
  }

  String _flowFailureMessage(Object error) {
    if (error is ApiError) {
      return switch (error.errorCode) {
        'GLOBAL_UNAUTHORIZED' ||
        'AUTH_ACCESS_TOKEN_MISSING' => '로그인이 만료됐어요. 다시 로그인해 주세요.',
        'GLOBAL_VALIDATION_ERROR' => '보낸 기록을 확인하지 못했어요. 다시 시도해 주세요.',
        _ => '다음 기록을 불러오지 못했어요. 잠시 뒤 다시 시도해 주세요.',
      };
    }

    if (_looksLikeNetworkError(error)) {
      return '서버에 연결하지 못했어요. 네트워크와 API 주소를 확인해 주세요.';
    }

    return '다음 기록을 불러오지 못했어요. 잠시 뒤 다시 시도해 주세요.';
  }

  bool _looksLikeNetworkError(Object error) {
    final message = error.toString();
    return message.contains('ClientException') ||
        message.contains('XMLHttpRequest error') ||
        message.contains('SocketException') ||
        message.contains('Failed host lookup') ||
        message.contains('Connection refused');
  }
}
