import '../learning_models.dart';

abstract interface class RecoveryRepository {
  RecoveryMission get firstMission;

  String nextAction({required bool missionCompleted});

  Future<RecoveryMission> createMission({required String diagnosticSessionId});

  Future<RecoveryMission> getMission(String recoveryMissionId);

  Future<RecoverySubmissionFeedback> submitMission({
    required String recoveryMissionId,
    required String answerText,
  });
}
