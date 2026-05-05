import '../diagnostic_models.dart';
import '../learning_models.dart';

abstract interface class DiagnosticRepository {
  List<DiagnosticQuestion> get questions;

  List<WeakLink> get weakLinks;

  Future<void> selectStartingPoint(String startingPoint);

  Future<DiagnosticSession> createSession();

  Future<List<DiagnosticQuestion>> getQuestions(String diagnosticSessionId);

  Future<DiagnosticResult> submitAnswers({
    required String diagnosticSessionId,
    required Map<String, DiagnosticAnswer> answers,
  });

  Future<DiagnosticResult> getResult(String diagnosticSessionId);
}
