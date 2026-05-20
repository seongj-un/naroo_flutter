class AuthProfile {
  const AuthProfile({
    required this.nickname,
    required this.email,
    required this.emailVerified,
  });

  final String nickname;
  final String email;
  final bool emailVerified;
}

class MathAreaOption {
  const MathAreaOption({
    required this.code,
    required this.name,
    required this.description,
    required this.recommendedFor,
    required this.displayOrder,
  });

  final String code;
  final String name;
  final String description;
  final String recommendedFor;
  final int displayOrder;
}

class WeakLink {
  const WeakLink({required this.title, required this.body});

  final String title;
  final String body;
}

class RecoveryMission {
  const RecoveryMission({
    this.id = '',
    this.diagnosticSessionId = '',
    required this.title,
    required this.estimatedTime,
    required this.explanation,
    required this.challenge,
    required this.hint,
    this.status = 'IN_PROGRESS',
  });

  final String id;
  final String diagnosticSessionId;
  final String title;
  final String estimatedTime;
  final String explanation;
  final String challenge;
  final String hint;
  final String status;
}

class LearningHome {
  const LearningHome({
    required this.nickname,
    required this.emailVerified,
    required this.nextAction,
    this.latestDiagnostic,
    this.todayMission,
    this.latestMission,
    this.completedMissionCount = 0,
    this.inProgressMissionCount = 0,
  });

  final String nickname;
  final bool emailVerified;
  final LearningNextAction nextAction;
  final LearningDiagnosticSummary? latestDiagnostic;
  final RecoveryMission? todayMission;
  final RecoveryMission? latestMission;
  final int completedMissionCount;
  final int inProgressMissionCount;
}

enum LearningNextAction {
  emailVerificationRequired,
  startDiagnostic,
  createRecoveryMission,
  continueRecoveryMission,
  recoverySeriesCompleted,
}

class LearningDiagnosticSummary {
  const LearningDiagnosticSummary({
    required this.diagnosticSessionId,
    required this.mathArea,
    required this.status,
    required this.totalQuestionCount,
    required this.correctCount,
    required this.wrongCount,
    required this.unknownCount,
    required this.weakLinks,
    required this.primaryRecoveryConcept,
    required this.summary,
  });

  final String diagnosticSessionId;
  final String mathArea;
  final String status;
  final int totalQuestionCount;
  final int correctCount;
  final int wrongCount;
  final int unknownCount;
  final List<String> weakLinks;
  final String primaryRecoveryConcept;
  final String summary;
}

class RecoverySubmissionFeedback {
  const RecoverySubmissionFeedback({
    required this.title,
    required this.message,
    required this.nextAction,
    required this.mission,
  });

  final String title;
  final String message;
  final String nextAction;
  final RecoveryMission mission;
}
