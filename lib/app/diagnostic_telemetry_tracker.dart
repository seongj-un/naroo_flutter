import 'package:flutter/foundation.dart';

import '../domain/diagnostic_models.dart';
import '../domain/repositories/diagnostic_repository.dart';

class DiagnosticTelemetryTracker {
  DiagnosticTelemetryTracker({required this.diagnosticRepository});

  final DiagnosticRepository diagnosticRepository;

  static const String _flowVariant = 'student-web-v1';
  static const String _resultCopyVersion = 'result-copy-v1';

  Future<void> recordQuestionShown({
    required String diagnosticSessionId,
    required DiagnosticQuestion question,
    required int questionIndex,
  }) {
    return _safeCall(() {
      return diagnosticRepository.recordQuestionShown(
        diagnosticSessionId: diagnosticSessionId,
        question: question,
        questionIndex: questionIndex,
        flowVariant: _flowVariant,
      );
    });
  }

  Future<void> recordAnswerSelected({
    required String diagnosticSessionId,
    required DiagnosticQuestion question,
    required DiagnosticAnswer answer,
    required int questionIndex,
  }) {
    return _safeCall(() {
      return diagnosticRepository.recordAnswerSelected(
        diagnosticSessionId: diagnosticSessionId,
        question: question,
        answer: answer,
        questionIndex: questionIndex,
        flowVariant: _flowVariant,
      );
    });
  }

  Future<void> recordSessionAbandoned({
    required String diagnosticSessionId,
    required DiagnosticQuestion question,
    required int questionIndex,
  }) {
    return _safeCall(() {
      return diagnosticRepository.recordSessionAbandoned(
        diagnosticSessionId: diagnosticSessionId,
        question: question,
        questionIndex: questionIndex,
        flowVariant: _flowVariant,
      );
    });
  }

  Future<void> submitResultTrustFeedback({
    required String diagnosticSessionId,
    required DiagnosticResultTrustFeedbackChoice feedbackChoice,
  }) {
    return _safeCall(() {
      return diagnosticRepository.submitResultTrustFeedback(
        diagnosticSessionId: diagnosticSessionId,
        feedbackChoice: feedbackChoice,
        flowVariant: _flowVariant,
        resultCopyVersion: _resultCopyVersion,
      );
    });
  }

  Future<void> _safeCall(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      debugPrint('Diagnostic telemetry failed: $error');
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'naroo_frontend',
          context: ErrorDescription('while sending diagnostic telemetry'),
        ),
      );
    }
  }
}
