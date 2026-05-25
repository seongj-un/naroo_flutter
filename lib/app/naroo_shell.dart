import 'package:flutter/material.dart';

import '../ui/common/naroo_widgets.dart';
import '../ui/screens/auth_screens.dart';
import '../ui/screens/learning_screens.dart';
import 'naroo_dependencies.dart';
import 'naroo_flow_controller.dart';

class NarooShell extends StatefulWidget {
  const NarooShell({
    super.key,
    required this.dependencies,
    this.initialVerificationToken,
    this.restoreSessionOnStartup = false,
  });

  final NarooDependencies dependencies;
  final String? initialVerificationToken;
  final bool restoreSessionOnStartup;

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
    final initialVerificationToken = widget.initialVerificationToken;
    if (initialVerificationToken != null &&
        initialVerificationToken.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.handleEmailVerificationLink(initialVerificationToken);
      });
      return;
    }

    if (widget.restoreSessionOnStartup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.restoreSessionIfPossible();
      });
    }
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
            statusMessage: _controller.authStatusMessage,
            onModeChanged: _controller.updateAuthMode,
            onBack: _controller.goToEntry,
            onSignup: _controller.submitSignup,
            onLogin: _controller.submitLogin,
          ),
          NarooStage.emailVerification => EmailVerificationScreen(
            email: _controller.email,
            isLoading: _controller.isAuthBusy,
            isLinkFlow: _controller.isVerificationLinkFlow,
            showLinkFailureState: _controller.showVerificationLinkFailureState,
            showResendAction: _controller.showResendVerificationAction,
            isResendCoolingDown: _controller.isResendCoolingDown,
            resendCooldownMessage: _controller.resendCooldownStatusText,
            errorMessage: _controller.authErrorMessage,
            statusMessage: _controller.authStatusMessage,
            onVerify: _controller.completeVerification,
            onResend: _controller.resendVerificationEmail,
            onUseCodeInstead:
                _controller.switchVerificationLinkFailureToCodeEntry,
            onBackToLogin: () => _controller.openAuth(AuthMode.login),
            onLater: _controller.skipVerificationForNow,
          ),
          NarooStage.home => LearningHomeScreen(
            nickname: _controller.nickname,
            emailVerified: _controller.emailVerified,
            title: _controller.homeActionTitle,
            body: _controller.homeActionBody,
            buttonLabel: _controller.homeActionButtonLabel,
            showSavedProgressShortcut: _controller.showSavedProgressShortcut,
            onPrimaryAction: () {
              _controller.openHomePrimaryAction();
            },
            onSavedProgress: _controller.goToSavedProgress,
          ),
          NarooStage.startingPoint => StartingPointScreen(
            selectedMathAreaCode: _controller.selectedMathAreaCode,
            options: _controller.mathAreas,
            onBack: () {
              _controller.goHome();
            },
            onSubmit: (mathArea) {
              _controller.startDiagnostic(mathArea);
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
            nextAction: _controller.savedProgressNextAction,
            buttonLabel: _controller.savedProgressButtonLabel,
            onHome: () {
              _controller.goHome();
            },
            onContinue: () {
              _controller.continueSavedProgress();
            },
          ),
        };

        return Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: child,
            ),
            FlowStatusOverlay(
              isLoading: _controller.isFlowBusy,
              errorMessage: _controller.flowErrorMessage,
            ),
          ],
        );
      },
    );
  }
}
