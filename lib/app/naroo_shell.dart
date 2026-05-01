import 'package:flutter/material.dart';

import '../data/mock_learning_content.dart';
import '../domain/diagnostic_models.dart';
import '../ui/screens/auth_screens.dart';
import '../ui/screens/learning_screens.dart';

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

class NarooShell extends StatefulWidget {
  const NarooShell({super.key});

  @override
  State<NarooShell> createState() => _NarooShellState();
}

class _NarooShellState extends State<NarooShell> {
  NarooStage _stage = NarooStage.entry;
  AuthMode _authMode = AuthMode.signup;
  String _nickname = '나루';
  String _email = '';
  String? _startingPoint;
  int _currentQuestionIndex = 0;
  final Map<String, DiagnosticAnswer> _diagnosticAnswers = {};
  bool _missionCompleted = false;
  bool _emailVerified = false;

  void _openAuth(AuthMode mode) {
    setState(() {
      _authMode = mode;
      _stage = NarooStage.auth;
    });
  }

  void _submitSignup({required String nickname, required String email}) {
    setState(() {
      _nickname = nickname.isEmpty ? '나루' : nickname;
      _email = email;
      _emailVerified = false;
      _stage = NarooStage.emailVerification;
    });
  }

  void _submitLogin({required String loginId}) {
    setState(() {
      _nickname = loginId.isEmpty ? '나루' : loginId;
      _emailVerified = true;
      _stage = NarooStage.home;
    });
  }

  void _completeVerification() {
    setState(() {
      _emailVerified = true;
      _stage = NarooStage.home;
    });
  }

  void _skipVerificationForNow() {
    setState(() => _stage = NarooStage.home);
  }

  void _startDiagnostic(String startingPoint) {
    setState(() {
      _startingPoint = startingPoint;
      _currentQuestionIndex = 0;
      _diagnosticAnswers.clear();
      _missionCompleted = false;
      _stage = NarooStage.diagnostic;
    });
  }

  void _submitDiagnosticAnswer(DiagnosticQuestion question, String? answerId) {
    setState(() {
      _diagnosticAnswers[question.id] = answerId == null
          ? const DiagnosticAnswer.unknown()
          : DiagnosticAnswer.selected(answerId);

      if (_currentQuestionIndex == diagnosticQuestions.length - 1) {
        _stage = NarooStage.result;
      } else {
        _currentQuestionIndex += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = switch (_stage) {
      NarooStage.entry => EntryScreen(
        onStart: () => _openAuth(AuthMode.signup),
        onExistingRecord: () => _openAuth(AuthMode.login),
      ),
      NarooStage.auth => AuthScreen(
        mode: _authMode,
        onModeChanged: (mode) => setState(() => _authMode = mode),
        onBack: () => setState(() => _stage = NarooStage.entry),
        onSignup: _submitSignup,
        onLogin: _submitLogin,
      ),
      NarooStage.emailVerification => EmailVerificationScreen(
        email: _email,
        onVerify: _completeVerification,
        onLater: _skipVerificationForNow,
      ),
      NarooStage.home => LearningHomeScreen(
        nickname: _nickname,
        emailVerified: _emailVerified,
        startingPoint: _startingPoint,
        hasDiagnosticResult:
            _diagnosticAnswers.length == diagnosticQuestions.length,
        missionCompleted: _missionCompleted,
        onVerifyEmail: () =>
            setState(() => _stage = NarooStage.emailVerification),
        onStartDiagnostic: () =>
            setState(() => _stage = NarooStage.startingPoint),
        onResumeResult: () => setState(() => _stage = NarooStage.result),
        onSavedProgress: () =>
            setState(() => _stage = NarooStage.savedProgress),
      ),
      NarooStage.startingPoint => StartingPointScreen(
        selectedStartingPoint: _startingPoint,
        onBack: () => setState(() => _stage = NarooStage.home),
        onSubmit: _startDiagnostic,
      ),
      NarooStage.diagnostic => DiagnosticQuestionScreen(
        key: ValueKey(diagnosticQuestions[_currentQuestionIndex].id),
        question: diagnosticQuestions[_currentQuestionIndex],
        questionIndex: _currentQuestionIndex,
        totalQuestions: diagnosticQuestions.length,
        onBack: () => setState(() => _stage = NarooStage.startingPoint),
        onSubmit: _submitDiagnosticAnswer,
      ),
      NarooStage.result => WeakLinkResultScreen(
        answers: _diagnosticAnswers,
        onStartRecovery: () =>
            setState(() => _stage = NarooStage.recoveryMission),
        onSaveForLater: () => setState(() => _stage = NarooStage.savedProgress),
      ),
      NarooStage.recoveryMission => RecoveryMissionScreen(
        onBack: () => setState(() => _stage = NarooStage.result),
        onSubmit: () => setState(() {
          _missionCompleted = true;
          _stage = NarooStage.missionFeedback;
        }),
      ),
      NarooStage.missionFeedback => MissionFeedbackScreen(
        onHome: () => setState(() => _stage = NarooStage.home),
        onSavedProgress: () =>
            setState(() => _stage = NarooStage.savedProgress),
      ),
      NarooStage.savedProgress => SavedProgressScreen(
        startingPoint: _startingPoint,
        missionCompleted: _missionCompleted,
        onHome: () => setState(() => _stage = NarooStage.home),
        onContinue: () => setState(() {
          _stage = _missionCompleted
              ? NarooStage.home
              : NarooStage.recoveryMission;
        }),
      ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: child,
    );
  }
}
