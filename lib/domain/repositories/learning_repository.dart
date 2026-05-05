import '../learning_models.dart';

abstract interface class LearningRepository {
  List<String> get mathStatusOptions;

  List<String> get startingPointOptions;

  Future<LearningHome> getLearningHome();
}
