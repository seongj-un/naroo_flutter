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
  LearningNextAction learningNextAction = LearningNextAction.startDiagnostic;
  String? diagnosticSessionId;
  int currentQuestionIndex = 0;
  final Map<String, DiagnosticAnswer> diagnosticAnswers = {};
  List<MathAreaOption> _mathAreas = const [];
  List<DiagnosticQuestion> _diagnosticQuestions = [];
  DiagnosticResult? diagnosticResult;
  RecoveryMission? activeRecoveryMission;
  RecoveryMission? latestRecoveryMission;
  RecoverySubmissionFeedback? recoveryFeedback;
  bool missionCompleted = false;
  bool emailVerified = false;
  int completedMissionCount = 0;
  int inProgressMissionCount = 0;
  bool isAuthBusy = false;
  bool isFlowBusy = false;
  String? authErrorMessage;
  String? authStatusMessage;
  String? flowErrorMessage;

  List<String> get mathStatusOptions => learningRepository.mathStatusOptions;

  List<MathAreaOption> get mathAreas => _mathAreas;

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

  String get homeActionTitle {
    if (!emailVerified ||
        learningNextAction == LearningNextAction.emailVerificationRequired) {
      return '이메일 확인이 필요해요';
    }

    return switch (learningNextAction) {
      LearningNextAction.emailVerificationRequired => '이메일 확인이 필요해요',
      LearningNextAction.startDiagnostic => '첫 진단을 시작할 수 있어요',
      LearningNextAction.createRecoveryMission => '약한 연결부터 다시 시작할 수 있어요',
      LearningNextAction.continueRecoveryMission => '진행 중인 복습을 이어갈 수 있어요',
      LearningNextAction.recoverySeriesCompleted => '이번 회복 미션을 모두 마쳤어요',
    };
  }

  String get homeActionBody {
    if (!emailVerified ||
        learningNextAction == LearningNextAction.emailVerificationRequired) {
      return '기록을 안전하게 저장한 뒤 시작 위치를 이어갈 수 있어요.';
    }

    return switch (learningNextAction) {
      LearningNextAction.emailVerificationRequired =>
        '기록을 안전하게 저장한 뒤 시작 위치를 이어갈 수 있어요.',
      LearningNextAction.startDiagnostic =>
        '아직 첫 기록이 없어요. 지금 가장 막히는 영역부터 가볍게 확인해 볼게요.',
      LearningNextAction.createRecoveryMission =>
        '진단 결과를 저장해뒀어요. 가장 먼저 다시 연결할 개념부터 10분 미션으로 이어갈 수 있어요.',
      LearningNextAction.continueRecoveryMission =>
        '오늘 미션이 이미 준비돼 있어요. 끊긴 자리부터 바로 이어가면 돼요.',
      LearningNextAction.recoverySeriesCompleted =>
        latestRecoveryMission == null
            ? '최근 회복 미션을 모두 마쳤어요. 저장된 기록을 보고 다음 학습 시작점을 정리할 수 있어요.'
            : '${latestRecoveryMission!.title}까지 마쳤어요. 저장된 기록을 보고 다음 학습 시작점을 정리할 수 있어요.',
    };
  }

  String get homeActionButtonLabel {
    if (!emailVerified ||
        learningNextAction == LearningNextAction.emailVerificationRequired) {
      return '이메일 인증하기';
    }

    return switch (learningNextAction) {
      LearningNextAction.emailVerificationRequired => '이메일 인증하기',
      LearningNextAction.startDiagnostic => '시작 위치 고르기',
      LearningNextAction.createRecoveryMission => '진단 결과 보기',
      LearningNextAction.continueRecoveryMission => '진행 중인 미션 이어가기',
      LearningNextAction.recoverySeriesCompleted => '저장된 기록 보기',
    };
  }

  String get savedProgressNextAction {
    return switch (learningNextAction) {
      LearningNextAction.emailVerificationRequired => '이메일 인증 후 이어서 진행해 주세요.',
      LearningNextAction.startDiagnostic => '시작 위치를 고르고 첫 진단을 시작해 주세요.',
      LearningNextAction.createRecoveryMission =>
        '진단 결과를 확인하고 첫 회복 미션을 시작해 주세요.',
      LearningNextAction.continueRecoveryMission => '진행 중인 회복 미션을 이어가 주세요.',
      LearningNextAction.recoverySeriesCompleted =>
        '최근 회복 미션을 모두 완료했어요. 저장된 기록을 확인해 주세요.',
    };
  }

  String get savedProgressButtonLabel {
    return switch (learningNextAction) {
      LearningNextAction.emailVerificationRequired => '이메일 인증하기',
      LearningNextAction.startDiagnostic => '시작 위치 고르기',
      LearningNextAction.createRecoveryMission => '진단 결과 보기',
      LearningNextAction.continueRecoveryMission => '미션 이어가기',
      LearningNextAction.recoverySeriesCompleted => '저장된 기록 보기',
    };
  }

  DiagnosticQuestion get currentQuestion =>
      diagnosticQuestions[currentQuestionIndex];

  bool get hasDiagnosticResult =>
      diagnosticResult != null ||
      diagnosticAnswers.length == diagnosticQuestions.length;

  void openAuth(AuthMode mode) {
    authMode = mode;
    authStatusMessage = null;
    authErrorMessage = null;
    stage = NarooStage.auth;
    notifyListeners();
  }

  void updateAuthMode(AuthMode mode) {
    authMode = mode;
    authStatusMessage = null;
    authErrorMessage = null;
    notifyListeners();
  }

  void goToEntry() {
    authStatusMessage = null;
    authErrorMessage = null;
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
      authStatusMessage = null;
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
      authStatusMessage = null;
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
      authStatusMessage = null;
      await _loadLearningHome();
    });
  }

  Future<void> handleEmailVerificationLink(String token) {
    stage = NarooStage.emailVerification;
    authStatusMessage = '인증 링크를 확인하는 중...';
    notifyListeners();

    return _runAuthAction(() async {
      final profile = await authRepository.verifyEmail(
        token: token,
        nickname: nickname,
        email: email,
      );
      nickname = profile.nickname;
      email = profile.email;
      emailVerified = profile.emailVerified;
      authMode = AuthMode.login;
      authStatusMessage = '이메일 인증이 완료됐어요. 로그인해 주세요.';
      stage = NarooStage.auth;
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

  Future<void> goToStartingPoint() {
    return _runFlowAction(() async {
      await _loadMathAreas();
      stage = NarooStage.startingPoint;
    });
  }

  Future<void> goHome() {
    return _runFlowAction(() async {
      await _loadLearningHome();
    });
  }

  Future<void> startDiagnostic(MathAreaOption mathArea) {
    return _runFlowAction(() async {
      startingPoint = mathArea.name;
      currentQuestionIndex = 0;
      diagnosticAnswers.clear();
      diagnosticResult = null;
      activeRecoveryMission = null;
      latestRecoveryMission = null;
      recoveryFeedback = null;
      missionCompleted = false;

      await diagnosticRepository.selectStartingPoint(mathArea);
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

  Future<void> openHomePrimaryAction() {
    if (!emailVerified ||
        learningNextAction == LearningNextAction.emailVerificationRequired) {
      goToEmailVerification();
      return Future.value();
    }

    return _runFlowAction(() async {
      switch (learningNextAction) {
        case LearningNextAction.emailVerificationRequired:
          stage = NarooStage.emailVerification;
          break;
        case LearningNextAction.startDiagnostic:
          await _loadMathAreas();
          stage = NarooStage.startingPoint;
          break;
        case LearningNextAction.createRecoveryMission:
          await _loadDiagnosticResult();
          stage = NarooStage.result;
          break;
        case LearningNextAction.continueRecoveryMission:
          await _resumeRecoveryMission();
          break;
        case LearningNextAction.recoverySeriesCompleted:
          stage = NarooStage.savedProgress;
          break;
      }
    });
  }

  Future<void> startRecoveryMission() {
    return _runFlowAction(_createRecoveryMission);
  }

  Future<void> completeRecoveryMission(String answerText) {
    return _runFlowAction(() async {
      final mission = activeRecoveryMission ?? recoveryRepository.firstMission;
      try {
        recoveryFeedback = await recoveryRepository.submitMission(
          recoveryMissionId: mission.id,
          answerText: answerText,
        );
        activeRecoveryMission = recoveryFeedback?.mission ?? mission;
        missionCompleted = true;
        stage = NarooStage.missionFeedback;
      } on ApiError catch (error) {
        if (error.errorCode == 'RECOVERY_MISSION_ALREADY_COMPLETED') {
          _showCompletedMissionFeedback(mission);
          return;
        }
        rethrow;
      }
    });
  }

  void goToSavedProgress() {
    stage = NarooStage.savedProgress;
    notifyListeners();
  }

  Future<void> continueSavedProgress() {
    return openHomePrimaryAction();
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    isAuthBusy = true;
    authErrorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      authStatusMessage = null;
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
    learningNextAction = home.nextAction;
    activeRecoveryMission = home.todayMission;
    latestRecoveryMission = home.latestMission;

    final latestDiagnostic = home.latestDiagnostic;
    if (latestDiagnostic != null) {
      startingPoint = _mathAreaLabel(latestDiagnostic.mathArea);
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
    } else {
      diagnosticSessionId = null;
      diagnosticResult = null;
    }

    missionCompleted =
        home.todayMission?.status == 'COMPLETED' ||
        home.nextAction == LearningNextAction.recoverySeriesCompleted;
    completedMissionCount = home.completedMissionCount;
    inProgressMissionCount = home.inProgressMissionCount;
    stage = NarooStage.home;
  }

  Future<void> _loadMathAreas() async {
    _mathAreas = await learningRepository.getMathAreas();
    if (_mathAreas.isEmpty) {
      throw StateError('Math areas are empty.');
    }
  }

  Future<void> _loadDiagnosticResult() async {
    final sessionId =
        diagnosticSessionId ?? diagnosticResult?.diagnosticSessionId;
    if (sessionId == null || sessionId.isEmpty) {
      throw StateError('Diagnostic result is missing.');
    }
    diagnosticResult = await diagnosticRepository.getResult(sessionId);
    startingPoint = _mathAreaLabel(diagnosticResult!.mathArea);
  }

  Future<void> _createRecoveryMission() async {
    final sessionId =
        diagnosticResult?.diagnosticSessionId ?? diagnosticSessionId;
    if (sessionId == null || sessionId.isEmpty) {
      throw StateError('Diagnostic result is missing.');
    }
    try {
      activeRecoveryMission = await recoveryRepository.createMission(
        diagnosticSessionId: sessionId,
      );
    } on ApiError catch (error) {
      if (error.errorCode == 'RECOVERY_MISSION_SERIES_COMPLETED') {
        await _loadLearningHome();
        return;
      }
      rethrow;
    }
    if (activeRecoveryMission?.status == 'COMPLETED') {
      _showCompletedMissionFeedback(activeRecoveryMission!);
      return;
    }
    stage = NarooStage.recoveryMission;
  }

  Future<void> _resumeRecoveryMission() async {
    final missionId = activeRecoveryMission?.id;
    if (missionId == null || missionId.isEmpty) {
      await _createRecoveryMission();
      return;
    }

    activeRecoveryMission = await recoveryRepository.getMission(missionId);
    if (activeRecoveryMission?.status == 'COMPLETED') {
      _showCompletedMissionFeedback(activeRecoveryMission!);
      return;
    }
    stage = NarooStage.recoveryMission;
  }

  void _showCompletedMissionFeedback(RecoveryMission mission) {
    activeRecoveryMission = mission;
    recoveryFeedback = RecoverySubmissionFeedback(
      title: '오늘 미션은 이미 완료됐어요.',
      message: '학습 홈으로 돌아가서 다음 상태를 확인해 주세요.',
      nextAction: recoveryRepository.nextAction(missionCompleted: true),
      mission: mission,
    );
    missionCompleted = true;
    stage = NarooStage.missionFeedback;
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
        'DIAGNOSTIC_EMAIL_VERIFICATION_REQUIRED' => '이메일 인증을 먼저 완료해 주세요.',
        'DIAGNOSTIC_RESULT_NOT_READY' => '진단 결과를 아직 만들지 못했어요. 잠시 뒤 다시 시도해 주세요.',
        'DIAGNOSTIC_ALREADY_COMPLETED' => '진단은 이미 완료됐어요. 저장된 결과를 다시 불러올게요.',
        'RECOVERY_MISSION_ALREADY_COMPLETED' =>
          '이 미션은 이미 끝났어요. 학습 홈 상태를 다시 불러와 주세요.',
        'RECOVERY_MISSION_SERIES_COMPLETED' =>
          '이번 회복 미션은 모두 마쳤어요. 저장된 기록을 확인해 주세요.',
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

  String _mathAreaLabel(String mathArea) {
    return switch (mathArea) {
      'EQUATION' => '방정식',
      'FUNCTION' => '함수',
      'GEOMETRY' => '도형',
      'PROBABILITY_AND_STATISTICS' => '확률과 통계',
      'SEQUENCE' => '수열',
      _ => '진단 결과',
    };
  }
}
