import 'dart:async';

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

enum AuthAction {
  signup,
  login,
  verifyCode,
  verifyLink,
  resendVerificationEmail,
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
  String? selectedMathAreaCode;
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
  bool isVerificationLinkFlow = false;
  bool hasAuthenticatedSession = false;
  bool showVerificationLinkFailureState = false;
  DateTime? verificationResendAvailableAt;
  Timer? _verificationResendTimer;
  String? authErrorMessage;
  String? authStatusMessage;
  String? flowErrorMessage;
  AuthAction? _currentAuthAction;

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

  bool get showSavedProgressShortcut {
    return learningNextAction != LearningNextAction.recoverySeriesCompleted;
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

  bool get canResendVerificationEmail =>
      hasAuthenticatedSession && !emailVerified;

  bool get showResendVerificationAction => canResendVerificationEmail;

  String? get resendCooldownStatusText => _verificationResendStatusText();

  bool get isResendCoolingDown {
    final availableAt = verificationResendAvailableAt;
    if (availableAt == null) {
      return false;
    }
    return DateTime.now().toUtc().isBefore(availableAt);
  }

  Duration? get resendCooldownRemaining {
    final availableAt = verificationResendAvailableAt;
    if (availableAt == null) {
      return null;
    }
    final remaining = availableAt.difference(DateTime.now().toUtc());
    if (remaining.isNegative || remaining.inSeconds <= 0) {
      return Duration.zero;
    }
    return remaining;
  }

  void openAuth(AuthMode mode) {
    authMode = mode;
    isVerificationLinkFlow = false;
    showVerificationLinkFailureState = false;
    verificationResendAvailableAt = null;
    _stopVerificationResendTimer();
    authStatusMessage = null;
    authErrorMessage = null;
    stage = NarooStage.auth;
    notifyListeners();
  }

  void updateAuthMode(AuthMode mode) {
    authMode = mode;
    isVerificationLinkFlow = false;
    showVerificationLinkFailureState = false;
    authStatusMessage = null;
    authErrorMessage = null;
    notifyListeners();
  }

  void goToEntry() {
    isVerificationLinkFlow = false;
    showVerificationLinkFailureState = false;
    verificationResendAvailableAt = null;
    _stopVerificationResendTimer();
    authStatusMessage = null;
    authErrorMessage = null;
    stage = NarooStage.entry;
    notifyListeners();
  }

  Future<void> restoreSessionIfPossible() async {
    isFlowBusy = true;
    flowErrorMessage = null;
    notifyListeners();

    try {
      await authRepository.reissue();
      await _loadLearningHome();
    } catch (_) {
      hasAuthenticatedSession = false;
      emailVerified = false;
      flowErrorMessage = null;
      stage = NarooStage.entry;
    } finally {
      isFlowBusy = false;
      notifyListeners();
    }
  }

  Future<void> submitSignup({
    required String loginId,
    required String email,
    required String password,
    required String nickname,
    required String mathStatus,
  }) {
    hasAuthenticatedSession = false;
    return _runAuthAction(AuthAction.signup, () async {
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
      isVerificationLinkFlow = false;
      showVerificationLinkFailureState = false;
      verificationResendAvailableAt = null;
      _stopVerificationResendTimer();
      authStatusMessage =
          '${profile.email}로 인증 링크를 보냈어요. 메일의 링크를 열거나 인증 코드를 붙여 넣어 주세요.';
      stage = NarooStage.emailVerification;
    });
  }

  Future<void> submitLogin({
    required String loginId,
    required String password,
  }) {
    return _runAuthAction(AuthAction.login, () async {
      final profile = await authRepository.login(
        loginId: loginId,
        password: password,
      );
      nickname = profile.nickname;
      email = profile.email;
      emailVerified = profile.emailVerified;
      hasAuthenticatedSession = true;
      isVerificationLinkFlow = false;
      showVerificationLinkFailureState = false;
      authStatusMessage = null;
      await _loadLearningHome();
    });
  }

  Future<void> completeVerification(String token) {
    return _runAuthAction(AuthAction.verifyCode, () async {
      final profile = await authRepository.verifyEmail(
        token: token,
        nickname: nickname,
        email: email,
      );
      nickname = profile.nickname;
      email = profile.email;
      emailVerified = profile.emailVerified;
      isVerificationLinkFlow = false;
      showVerificationLinkFailureState = false;
      authStatusMessage = null;
      await _loadLearningHome();
    });
  }

  Future<void> resendVerificationEmail() async {
    if (!canResendVerificationEmail || isResendCoolingDown) {
      notifyListeners();
      return;
    }

    isAuthBusy = true;
    authErrorMessage = null;
    authStatusMessage = null;
    _currentAuthAction = AuthAction.resendVerificationEmail;
    notifyListeners();

    try {
      final result = await authRepository.resendVerificationEmail();
      email = result.email;
      emailVerified = result.emailVerified;
      hasAuthenticatedSession = true;
      _setVerificationResendCooldown(result.nextRetryAt);
      authStatusMessage = '${result.email}로 인증 메일을 다시 보냈어요.';
      showVerificationLinkFailureState = false;
    } on ApiError catch (error) {
      if (error.errorCode == 'AUTH_UNAUTHORIZED') {
        isVerificationLinkFlow = false;
        showVerificationLinkFailureState = false;
        authMode = AuthMode.login;
        authErrorMessage = null;
        authStatusMessage = '인증 메일을 다시 보내려면 먼저 로그인해 주세요.';
        stage = NarooStage.auth;
      } else if (error.errorCode == 'AUTH_EMAIL_ALREADY_VERIFIED') {
        emailVerified = true;
        authErrorMessage = null;
        authStatusMessage = '이미 이메일 인증이 완료된 계정이에요. 학습 홈으로 이동할게요.';
        await _loadLearningHome();
      } else if (error.errorCode == 'AUTH_EMAIL_VERIFICATION_RESEND_TOO_SOON') {
        _setVerificationResendCooldown(_retryAtFromError(error));
        authStatusMessage = null;
      } else {
        authStatusMessage = null;
        authErrorMessage = _authFailureMessage(error);
      }
    } catch (error) {
      authStatusMessage = null;
      authErrorMessage = _authFailureMessage(error);
    } finally {
      isAuthBusy = false;
      notifyListeners();
    }
  }

  Future<void> handleEmailVerificationLink(String token) {
    isVerificationLinkFlow = true;
    showVerificationLinkFailureState = false;
    stage = NarooStage.emailVerification;
    authStatusMessage = '인증 링크를 확인하는 중...';
    return _runAuthAction(AuthAction.verifyLink, () async {
      final profile = await authRepository.verifyEmail(
        token: token,
        nickname: nickname,
        email: email,
      );
      nickname = profile.nickname;
      email = profile.email;
      emailVerified = profile.emailVerified;
      isVerificationLinkFlow = false;
      showVerificationLinkFailureState = false;
      authMode = AuthMode.login;
      authStatusMessage = '이메일 인증이 완료됐어요. 로그인해 주세요.';
      stage = NarooStage.auth;
    });
  }

  void skipVerificationForNow() {
    isVerificationLinkFlow = false;
    showVerificationLinkFailureState = false;
    verificationResendAvailableAt = null;
    _stopVerificationResendTimer();
    stage = NarooStage.home;
    notifyListeners();
  }

  void goToEmailVerification() {
    isVerificationLinkFlow = false;
    showVerificationLinkFailureState = false;
    stage = NarooStage.emailVerification;
    notifyListeners();
  }

  void switchVerificationLinkFailureToCodeEntry() {
    isVerificationLinkFlow = false;
    showVerificationLinkFailureState = false;
    authErrorMessage = null;
    authStatusMessage = '메일에 적힌 인증 코드를 붙여 넣어 주세요.';
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
      selectedMathAreaCode = mathArea.code;
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

  Future<void> _runAuthAction(
    AuthAction action,
    Future<void> Function() actionBody,
  ) async {
    isAuthBusy = true;
    authErrorMessage = null;
    _currentAuthAction = action;
    notifyListeners();

    try {
      await actionBody();
    } catch (error) {
      authStatusMessage = null;
      if (action == AuthAction.verifyLink) {
        await _handleVerificationLinkFailure(error);
      } else {
        authErrorMessage = _authFailureMessage(error);
      }
      if (action == AuthAction.verifyLink) {
        showVerificationLinkFailureState = true;
      }
    } finally {
      isAuthBusy = false;
      _currentAuthAction = null;
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
      selectedMathAreaCode = latestDiagnostic.mathArea;
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
      selectedMathAreaCode = null;
      diagnosticSessionId = null;
      diagnosticResult = null;
    }

    missionCompleted =
        home.todayMission?.status == 'COMPLETED' ||
        home.nextAction == LearningNextAction.recoverySeriesCompleted;
    hasAuthenticatedSession = true;
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
    selectedMathAreaCode = diagnosticResult!.mathArea;
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
    final action = _currentAuthAction;
    if (error is ApiError) {
      switch (action) {
        case AuthAction.signup:
          return switch (error.errorCode) {
            'AUTH_EMAIL_ALREADY_EXISTS' =>
              '이미 가입된 이메일이에요. 바로 로그인하거나 다른 이메일을 사용해 주세요.',
            'AUTH_LOGIN_ID_ALREADY_EXISTS' =>
              '이미 사용 중인 아이디예요. 다른 아이디로 다시 시도해 주세요.',
            'GLOBAL_VALIDATION_ERROR' => '회원가입 정보를 다시 확인해 주세요.',
            _ => '회원가입을 완료하지 못했어요. 잠시 뒤 다시 시도해 주세요.',
          };
        case AuthAction.login:
          return switch (error.errorCode) {
            'AUTH_INVALID_CREDENTIALS' ||
            'AUTH_UNAUTHORIZED' => '아이디나 비밀번호가 맞지 않아요. 다시 확인해 주세요.',
            'GLOBAL_VALIDATION_ERROR' => '로그인 정보를 다시 확인해 주세요.',
            _ => '로그인하지 못했어요. 잠시 뒤 다시 시도해 주세요.',
          };
        case AuthAction.verifyCode:
          return switch (error.errorCode) {
            'AUTH_INVALID_EMAIL_VERIFICATION_TOKEN' =>
              '인증 코드가 올바르지 않아요. 메일의 최신 코드를 다시 확인해 주세요.',
            'AUTH_EMAIL_ALREADY_VERIFIED' => '이미 이메일 인증이 완료된 계정이에요.',
            _ => '이메일 인증을 완료하지 못했어요. 잠시 뒤 다시 시도해 주세요.',
          };
        case AuthAction.verifyLink:
          return switch (error.errorCode) {
            'AUTH_INVALID_EMAIL_VERIFICATION_TOKEN' =>
              '인증 링크가 만료됐거나 이미 사용됐어요. 메일에서 최신 링크를 다시 열어 주세요.',
            'AUTH_EMAIL_ALREADY_VERIFIED' => '이미 이메일 인증이 완료된 계정이에요. 로그인해 주세요.',
            _ => '인증 링크를 확인하지 못했어요. 잠시 뒤 다시 시도해 주세요.',
          };
        case AuthAction.resendVerificationEmail:
          if (error.errorCode == 'AUTH_EMAIL_VERIFICATION_RESEND_TOO_SOON') {
            return _verificationResendStatusText() ??
                '방금 인증 메일을 보냈어요. 잠시 후 다시 시도해 주세요.';
          }
          return switch (error.errorCode) {
            'AUTH_EMAIL_ALREADY_VERIFIED' => '이미 이메일 인증이 완료된 계정이에요.',
            'AUTH_UNAUTHORIZED' => '인증 메일을 다시 보내려면 먼저 로그인해 주세요.',
            _ => '인증 메일을 다시 보내지 못했어요. 잠시 뒤 다시 시도해 주세요.',
          };
        case null:
          break;
      }

      return switch (error.errorCode) {
        'AUTH_ACCESS_TOKEN_MISSING' ||
        'GLOBAL_UNAUTHORIZED' => '로그인이 만료됐어요. 다시 로그인해 주세요.',
        _ => '인증 상태를 확인하지 못했어요. 잠시 뒤 다시 시도해 주세요.',
      };
    }

    if (_looksLikeNetworkError(error)) {
      return switch (action) {
        AuthAction.signup => '회원가입 서버에 연결하지 못했어요. 네트워크 상태를 확인해 주세요.',
        AuthAction.login => '로그인 서버에 연결하지 못했어요. 네트워크 상태를 확인해 주세요.',
        AuthAction.verifyCode ||
        AuthAction.verifyLink => '이메일 인증 서버에 연결하지 못했어요. 네트워크 상태를 확인해 주세요.',
        AuthAction.resendVerificationEmail =>
          '인증 메일 서버에 연결하지 못했어요. 네트워크 상태를 확인해 주세요.',
        null => '서버에 연결하지 못했어요. 네트워크와 API 주소를 확인해 주세요.',
      };
    }

    return switch (action) {
      AuthAction.signup => '회원가입을 완료하지 못했어요. 잠시 뒤 다시 시도해 주세요.',
      AuthAction.login => '로그인하지 못했어요. 잠시 뒤 다시 시도해 주세요.',
      AuthAction.verifyCode ||
      AuthAction.verifyLink => '이메일 인증을 완료하지 못했어요. 잠시 뒤 다시 시도해 주세요.',
      AuthAction.resendVerificationEmail =>
        '인증 메일을 다시 보내지 못했어요. 잠시 뒤 다시 시도해 주세요.',
      null => '인증 상태를 확인하지 못했어요. 잠시 뒤 다시 시도해 주세요.',
    };
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

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String? _verificationResendStatusText() {
    final remaining = resendCooldownRemaining;
    if (remaining == null || remaining == Duration.zero) {
      return null;
    }
    return '다시 보내기까지 ${_formatDuration(remaining)} 남았어요.';
  }

  DateTime _retryAtFromError(ApiError error) {
    final retryAfter = error.headers['retry-after'];
    if (retryAfter != null) {
      final seconds = int.tryParse(retryAfter);
      if (seconds != null && seconds > 0) {
        return DateTime.now().toUtc().add(Duration(seconds: seconds));
      }
      final absolute = DateTime.tryParse(retryAfter);
      if (absolute != null) {
        return absolute.toUtc();
      }
    }

    final availableAt = verificationResendAvailableAt;
    if (availableAt != null) {
      return availableAt;
    }
    return DateTime.now().toUtc().add(const Duration(seconds: 60));
  }

  void _setVerificationResendCooldown(DateTime nextRetryAt) {
    verificationResendAvailableAt = nextRetryAt.toUtc();
    _restartVerificationResendTimer();
  }

  void _restartVerificationResendTimer() {
    _stopVerificationResendTimer();
    if (!isResendCoolingDown) {
      verificationResendAvailableAt = null;
      return;
    }
    _verificationResendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isResendCoolingDown) {
        verificationResendAvailableAt = null;
        _stopVerificationResendTimer();
      }
      notifyListeners();
    });
  }

  void _stopVerificationResendTimer() {
    _verificationResendTimer?.cancel();
    _verificationResendTimer = null;
  }

  Future<void> _handleVerificationLinkFailure(Object error) async {
    authErrorMessage = _authFailureMessage(error);
    showVerificationLinkFailureState = true;

    try {
      await authRepository.reissue();
      final profile = await authRepository.me();
      nickname = profile.nickname;
      email = profile.email;
      emailVerified = profile.emailVerified;
      hasAuthenticatedSession = true;
      return;
    } catch (_) {
      hasAuthenticatedSession = false;
    }
  }

  @override
  void dispose() {
    _stopVerificationResendTimer();
    super.dispose();
  }
}
