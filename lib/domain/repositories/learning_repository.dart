import '../learning_models.dart';

abstract interface class LearningRepository {
  List<String> get mathStatusOptions;

  Future<List<MathAreaOption>> getMathAreas();

  Future<LearningHome> getLearningHome();
}
