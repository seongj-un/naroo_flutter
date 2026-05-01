import '../learning_models.dart';

abstract interface class RecoveryRepository {
  RecoveryMission get firstMission;

  String nextAction({required bool missionCompleted});
}
