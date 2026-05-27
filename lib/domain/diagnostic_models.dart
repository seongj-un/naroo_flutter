class DiagnosticQuestion {
  const DiagnosticQuestion({
    required this.id,
    required this.concept,
    required this.prompt,
    required this.choices,
    this.correctAnswerId,
  });

  final String id;
  final String concept;
  final String prompt;
  final List<AnswerChoice> choices;
  final String? correctAnswerId;
}

class AnswerChoice {
  const AnswerChoice({required this.id, required this.label});

  final String id;
  final String label;
}

class DiagnosticAnswer {
  const DiagnosticAnswer.selected(this.answerId) : isUnknown = false;

  const DiagnosticAnswer.unknown() : answerId = null, isUnknown = true;

  final String? answerId;
  final bool isUnknown;
}

class DiagnosticSession {
  const DiagnosticSession({
    required this.id,
    required this.mathArea,
    required this.status,
  });

  final String id;
  final String mathArea;
  final String status;
}

class DiagnosticResult {
  const DiagnosticResult({
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
    this.nextMissionTitle,
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
  final String? nextMissionTitle;
}

enum DiagnosticResultTrustFeedbackChoice { feelsRight, unsure }
