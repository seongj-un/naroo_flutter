class DiagnosticQuestion {
  const DiagnosticQuestion({
    required this.id,
    required this.concept,
    required this.prompt,
    required this.choices,
    required this.correctAnswerId,
  });

  final String id;
  final String concept;
  final String prompt;
  final List<AnswerChoice> choices;
  final String correctAnswerId;
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
