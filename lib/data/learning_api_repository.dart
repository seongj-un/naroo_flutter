import '../api/api_client.dart';
import '../api/api_types.dart';
import '../domain/learning_models.dart';
import '../domain/repositories/learning_repository.dart';
import 'repository_decoders.dart';

class LearningApiRepository implements LearningRepository {
  const LearningApiRepository({required this.apiClient});

  final ApiClient apiClient;

  @override
  List<String> get mathStatusOptions => const [
    '수업을 따라가고 있어요',
    '간신히 따라가고 있어요',
    '거의 놓친 것 같아요',
    '아직 모르겠어요',
  ];

  @override
  List<String> get startingPointOptions => const [
    '식을 어떻게 바꿀지 모르겠어요',
    '함수 그래프가 나오면 막혀요',
    '도형 조건을 어디에 써야 할지 모르겠어요',
    '확률과 통계에서 기준을 못 잡겠어요',
    '수열 규칙을 식으로 못 바꾸겠어요',
    '어디서부터 다시 해야 할지 모르겠어요',
  ];

  @override
  Future<LearningHome> getLearningHome() {
    return apiClient.get('/api/me/learning-home', decode: _homeFromData);
  }

  LearningHome _homeFromData(Object? data) {
    final object = requireObject(data);
    final user = requireObject(object['user']);
    final progress = objectFromData(object['progress']);

    return LearningHome(
      nickname: stringFromData(user['nickname'], fallback: '나루'),
      emailVerified: user['emailVerified'] == true,
      nextAction: _nextActionFromData(object['nextAction']),
      latestDiagnostic: _diagnosticSummaryFromData(object['latestDiagnostic']),
      todayMission: recoveryMissionFromDataOrNull(object['todayMission']),
      completedMissionCount: intFromData(progress['completedMissionCount']),
      inProgressMissionCount: intFromData(progress['inProgressMissionCount']),
    );
  }

  LearningNextAction _nextActionFromData(Object? data) {
    return switch (data) {
      'EMAIL_VERIFICATION_REQUIRED' =>
        LearningNextAction.emailVerificationRequired,
      'CREATE_RECOVERY_MISSION' => LearningNextAction.createRecoveryMission,
      'CONTINUE_RECOVERY_MISSION' => LearningNextAction.continueRecoveryMission,
      _ => LearningNextAction.startDiagnostic,
    };
  }

  LearningDiagnosticSummary? _diagnosticSummaryFromData(Object? data) {
    if (data == null) {
      return null;
    }
    final object = requireObject(data);

    return LearningDiagnosticSummary(
      diagnosticSessionId: stringFromData(object['diagnosticSessionId']),
      mathArea: stringFromData(object['mathArea']),
      status: stringFromData(object['status']),
      totalQuestionCount: intFromData(object['totalQuestionCount']),
      correctCount: intFromData(object['correctCount']),
      wrongCount: intFromData(object['wrongCount']),
      unknownCount: intFromData(object['unknownCount']),
      weakLinks: stringListFromData(object['weakLinks']),
      primaryRecoveryConcept: stringFromData(object['primaryRecoveryConcept']),
      summary: stringFromData(object['summary']),
    );
  }
}

class MathAreaRequest {
  const MathAreaRequest({
    required this.selectionType,
    this.mathArea,
    this.note,
  });

  final String selectionType;
  final String? mathArea;
  final String? note;

  JsonMap toJson() => {
    'selectionType': selectionType,
    if (mathArea != null) 'mathArea': mathArea,
    if (note != null) 'note': note,
  };
}
