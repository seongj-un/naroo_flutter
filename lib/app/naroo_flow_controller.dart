import 'package:flutter/foundation.dart';

import '../data/mock_learning_content.dart';
import '../domain/diagnostic_models.dart';
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
  NarooStage stage = NarooStage.entry;
  AuthMode authMode = AuthMode.signup;
  String nickname = '나루';
  String email = '';
  String? startingPoint;
  int currentQuestionIndex = 0;
  final Map<String, DiagnosticAnswer> diagnosticAnswers = {};
  bool missionCompleted = false;
  bool emailVerified = false;

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
    this.nickname = nickname.isEmpty ? '나루' : nickname;
    this.email = email;
    emailVerified = false;
    stage = NarooStage.emailVerification;
    notifyListeners();
  }

  void submitLogin({required String loginId}) {
    nickname = loginId.isEmpty ? '나루' : loginId;
    emailVerified = true;
    stage = NarooStage.home;
    notifyListeners();
  }

  void completeVerification() {
    emailVerified = true;
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
