import '../diagnostic_models.dart';
import '../learning_models.dart';

abstract interface class DiagnosticRepository {
  List<DiagnosticQuestion> get questions;

  List<WeakLink> get weakLinks;
}
