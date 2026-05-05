import '../api/api_client.dart';
import '../domain/learning_models.dart';
import '../domain/repositories/recovery_repository.dart';
import 'repository_decoders.dart';

class RecoveryApiRepository implements RecoveryRepository {
  const RecoveryApiRepository({required this.apiClient});

  final ApiClient apiClient;

  @override
  RecoveryMission get firstMission => const RecoveryMission(
    title: '10분 회복 미션',
    estimatedTime: '예상 시간 10분',
    explanation: '진단 결과를 제출하면 맞춤 미션을 불러올게요.',
    challenge: '아직 생성된 미션이 없어요.',
    hint: '먼저 진단을 완료해 주세요.',
  );

  @override
  String nextAction({required bool missionCompleted}) {
    return missionCompleted
        ? '학습 홈에서 다음 행동을 확인해 주세요.'
        : '진행 중인 회복 미션을 이어갈 수 있어요.';
  }

  @override
  Future<RecoveryMission> createMission({required String diagnosticSessionId}) {
    return apiClient.post(
      '/api/recovery-missions',
      body: {'diagnosticSessionId': diagnosticSessionId},
      decode: recoveryMissionFromData,
    );
  }

  @override
  Future<RecoveryMission> getMission(String recoveryMissionId) {
    return apiClient.get(
      '/api/recovery-missions/$recoveryMissionId',
      decode: recoveryMissionFromData,
    );
  }

  @override
  Future<RecoverySubmissionFeedback> submitMission({
    required String recoveryMissionId,
    required String answerText,
  }) {
    return apiClient.post(
      '/api/recovery-missions/$recoveryMissionId/submissions',
      body: {'answerText': answerText},
      decode: (data) {
        final object = requireObject(data);
        return RecoverySubmissionFeedback(
          title: stringFromData(object['feedbackTitle'], fallback: '좋아요'),
          message: stringFromData(
            object['feedbackMessage'],
            fallback: '오늘 미션을 저장했어요.',
          ),
          nextAction: stringFromData(
            object['nextAction'],
            fallback: '학습 홈에서 다음 행동을 확인해 주세요.',
          ),
          mission: recoveryMissionFromData(object['mission']),
        );
      },
    );
  }
}
