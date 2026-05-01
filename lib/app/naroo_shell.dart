import 'package:flutter/material.dart';

import '../data/mock_repositories.dart';
import '../ui/screens/auth_screens.dart';
import '../ui/screens/learning_screens.dart';
import 'naroo_flow_controller.dart';

class NarooShell extends StatefulWidget {
  const NarooShell({super.key});

  @override
  State<NarooShell> createState() => _NarooShellState();
}

class _NarooShellState extends State<NarooShell> {
  late final NarooFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NarooFlowController(
      authRepository: MockAuthRepository(),
      learningRepository: MockLearningRepository(),
      diagnosticRepository: MockDiagnosticRepository(),
      recoveryRepository: MockRecoveryRepository(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final child = switch (_controller.stage) {
          NarooStage.entry => EntryScreen(
            onStart: () => _controller.openAuth(AuthMode.signup),
            onExistingRecord: () => _controller.openAuth(AuthMode.login),
          ),
          NarooStage.auth => AuthScreen(
            mode: _controller.authMode,
            mathStatusOptions: _controller.mathStatusOptions,
            onModeChanged: _controller.updateAuthMode,
            onBack: _controller.goToEntry,
            onSignup: _controller.submitSignup,
            onLogin: _controller.submitLogin,
          ),
          NarooStage.emailVerification => EmailVerificationScreen(
            email: _controller.email,
            onVerify: _controller.completeVerification,
            onLater: _controller.skipVerificationForNow,
          ),
          NarooStage.home => LearningHomeScreen(
            nickname: _controller.nickname,
            emailVerified: _controller.emailVerified,
            startingPoint: _controller.startingPoint,
            hasDiagnosticResult: _controller.hasDiagnosticResult,
            missionCompleted: _controller.missionCompleted,
            onVerifyEmail: _controller.goToEmailVerification,
            onStartDiagnostic: _controller.goToStartingPoint,
            onResumeResult: _controller.goToResult,
            onSavedProgress: _controller.goToSavedProgress,
          ),
          NarooStage.startingPoint => StartingPointScreen(
            selectedStartingPoint: _controller.startingPoint,
            options: _controller.startingPointOptions,
            onBack: _controller.goHome,
            onSubmit: _controller.startDiagnostic,
          ),
          NarooStage.diagnostic => DiagnosticQuestionScreen(
            key: ValueKey(_controller.currentQuestion.id),
            question: _controller.currentQuestion,
            questionIndex: _controller.currentQuestionIndex,
            totalQuestions: _controller.diagnosticQuestions.length,
            onBack: _controller.backToStartingPoint,
            onSubmit: _controller.submitDiagnosticAnswer,
          ),
          NarooStage.result => WeakLinkResultScreen(
            answers: _controller.diagnosticAnswers,
            questions: _controller.diagnosticQuestions,
            weakLinks: _controller.weakLinks,
            onStartRecovery: _controller.startRecoveryMission,
            onSaveForLater: _controller.goToSavedProgress,
          ),
          NarooStage.recoveryMission => RecoveryMissionScreen(
            mission: _controller.recoveryMission,
            onBack: _controller.goToResult,
            onSubmit: _controller.completeRecoveryMission,
          ),
          NarooStage.missionFeedback => MissionFeedbackScreen(
            onHome: _controller.goHome,
            onSavedProgress: _controller.goToSavedProgress,
          ),
          NarooStage.savedProgress => SavedProgressScreen(
            startingPoint: _controller.startingPoint,
            missionCompleted: _controller.missionCompleted,
            nextAction: _controller.savedProgressNextAction,
            onHome: _controller.goHome,
            onContinue: _controller.continueSavedProgress,
          ),
        };

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: child,
        );
      },
    );
  }
}
