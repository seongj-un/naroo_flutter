import 'package:flutter/foundation.dart';

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
  int currentQuestionIndex = 0;
  final Map<String, DiagnosticAnswer> diagnosticAnswers = {};
  bool missionCompleted = false;
  bool emailVerified = false;
  bool isAuthBusy = false;
  String? authErrorMessage;

  List<String> get mathStatusOptions => learningRepository.mathStatusOptions;

  List<String> get startingPointOptions =>
      learningRepository.startingPointOptions;

  List<DiagnosticQuestion> get diagnosticQuestions =>
      diagnosticRepository.questions;

  List<WeakLink> get weakLinks => diagnosticRepository.weakLinks;

  RecoveryMission get recoveryMission => recoveryRepository.firstMission;

  String get savedProgressNextAction =>
      recoveryRepository.nextAction(missionCompleted: missionCompleted);

  DiagnosticQuestion get currentQuestion =>
      diagnosticQuestions[currentQuestionIndex];

  bool get hasDiagnosticResult =>
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
      stage = NarooStage.home;
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
      stage = NarooStage.home;
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

  void goHome() {
    stage = NarooStage.home;
    notifyListeners();
  }

  void startDiagnostic(String startingPoint) {
    this.startingPoint = startingPoint;
    currentQuestionIndex = 0;
    diagnosticAnswers.clear();
    missionCompleted = false;
    stage = NarooStage.diagnostic;
    notifyListeners();
  }

  void backToStartingPoint() {
    stage = NarooStage.startingPoint;
    notifyListeners();
  }

  void submitDiagnosticAnswer(DiagnosticQuestion question, String? answerId) {
    diagnosticAnswers[question.id] = answerId == null
        ? const DiagnosticAnswer.unknown()
        : DiagnosticAnswer.selected(answerId);

    if (currentQuestionIndex == diagnosticQuestions.length - 1) {
      stage = NarooStage.result;
    } else {
      currentQuestionIndex += 1;
    }
    notifyListeners();
  }

  void goToResult() {
    stage = NarooStage.result;
    notifyListeners();
  }

  void startRecoveryMission() {
    stage = NarooStage.recoveryMission;
    notifyListeners();
  }

  void completeRecoveryMission() {
    missionCompleted = true;
    stage = NarooStage.missionFeedback;
    notifyListeners();
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
    } catch (_) {
      authErrorMessage = '기록을 불러오지 못했어요. 다시 시도해 주세요';
    } finally {
      isAuthBusy = false;
      notifyListeners();
    }
  }
}
