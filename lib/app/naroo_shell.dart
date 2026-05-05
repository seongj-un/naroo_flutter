import 'package:flutter/material.dart';

import '../ui/screens/auth_screens.dart';
import '../ui/screens/learning_screens.dart';
import 'naroo_dependencies.dart';
import 'naroo_flow_controller.dart';

class NarooShell extends StatefulWidget {
  const NarooShell({super.key, required this.dependencies});

  final NarooDependencies dependencies;

  @override
  State<NarooShell> createState() => _NarooShellState();
}

class _NarooShellState extends State<NarooShell> {
  late final NarooFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NarooFlowController(
      authRepository: widget.dependencies.authRepository,
      learningRepository: widget.dependencies.learningRepository,
      diagnosticRepository: widget.dependencies.diagnosticRepository,
      recoveryRepository: widget.dependencies.recoveryRepository,
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
            isLoading: _controller.isAuthBusy,
            errorMessage: _controller.authErrorMessage,
            onModeChanged: _controller.updateAuthMode,
            onBack: _controller.goToEntry,
            onSignup: _controller.submitSignup,
            onLogin: _controller.submitLogin,
          ),
          NarooStage.emailVerification => EmailVerificationScreen(
            email: _controller.email,
            isLoading: _controller.isAuthBusy,
            errorMessage: _controller.authErrorMessage,
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
            onBack: () {
              _controller.goHome();
            },
            onSubmit: (startingPoint) {
              _controller.startDiagnostic(startingPoint);
            },
          ),
          NarooStage.diagnostic => DiagnosticQuestionScreen(
            key: ValueKey(_controller.currentQuestion.id),
            question: _controller.currentQuestion,
            questionIndex: _controller.currentQuestionIndex,
            totalQuestions: _controller.diagnosticQuestions.length,
            onBack: _controller.backToStartingPoint,
            onSubmit: (question, answerId) {
              _controller.submitDiagnosticAnswer(question, answerId);
            },
          ),
          NarooStage.result => WeakLinkResultScreen(
            result: _controller.diagnosticResult!,
            weakLinks: _controller.weakLinks,
            onStartRecovery: () {
              _controller.startRecoveryMission();
            },
            onSaveForLater: _controller.goToSavedProgress,
          ),
          NarooStage.recoveryMission => RecoveryMissionScreen(
            mission: _controller.recoveryMission,
            onBack: _controller.goToResult,
            onSubmit: (answerText) {
              _controller.completeRecoveryMission(answerText);
            },
          ),
          NarooStage.missionFeedback => MissionFeedbackScreen(
            title: _controller.recoveryFeedback?.title ?? '오늘은 여기까지만 해도 충분해요.',
            message:
                _controller.recoveryFeedback?.message ??
                '미션을 완료했어요. 다음에는 저장된 위치에서 이어갈게요.',
            onHome: () {
              _controller.goHome();
            },
            onSavedProgress: _controller.goToSavedProgress,
          ),
          NarooStage.savedProgress => SavedProgressScreen(
            startingPoint: _controller.startingPoint,
            missionCompleted: _controller.missionCompleted,
            nextAction: _controller.savedProgressNextAction,
            onHome: () {
              _controller.goHome();
            },
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
