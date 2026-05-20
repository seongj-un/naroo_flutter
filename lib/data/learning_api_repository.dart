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
  Future<LearningHome> getLearningHome() {
    return apiClient.get('/api/me/learning-home', decode: _homeFromData);
  }

  @override
  Future<List<MathAreaOption>> getMathAreas() {
    return apiClient.get(
      '/api/math-areas',
      auth: false,
      decode: (data) {
        if (data is! List) {
          return const <MathAreaOption>[];
        }

        final areas = data
            .map((areaData) {
              final area = requireObject(areaData);
              return MathAreaOption(
                code: stringFromData(area['code']),
                name: stringFromData(area['name']),
                description: stringFromData(area['description']),
                recommendedFor: stringFromData(area['recommendedFor']),
                displayOrder: intFromData(area['displayOrder']),
              );
            })
            .where((area) => area.code.isNotEmpty && area.name.isNotEmpty)
            .toList(growable: false);

        areas.sort((left, right) {
          final order = left.displayOrder.compareTo(right.displayOrder);
          if (order != 0) {
            return order;
          }
          return left.name.compareTo(right.name);
        });
        return areas;
      },
    );
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
      latestMission: recoveryMissionFromDataOrNull(object['latestMission']),
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
      'RECOVERY_SERIES_COMPLETED' =>
        LearningNextAction.recoverySeriesCompleted,
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
