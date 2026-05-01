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

  void submitSignup({required String nickname, required String email}) {
    final profile = authRepository.signUp(nickname: nickname, email: email);
    this.nickname = profile.nickname;
    this.email = profile.email;
    emailVerified = profile.emailVerified;
    stage = NarooStage.emailVerification;
    notifyListeners();
  }

  void submitLogin({required String loginId}) {
    final profile = authRepository.login(loginId: loginId);
    nickname = profile.nickname;
    email = profile.email;
    emailVerified = profile.emailVerified;
    stage = NarooStage.home;
    notifyListeners();
  }

  void completeVerification() {
    final profile = authRepository.verifyEmail(
      nickname: nickname,
      email: email,
    );
    nickname = profile.nickname;
    email = profile.email;
    emailVerified = profile.emailVerified;
    stage = NarooStage.home;
    notifyListeners();
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
}
