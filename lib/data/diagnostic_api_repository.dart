import '../api/api_client.dart';
import '../domain/diagnostic_models.dart';
import '../domain/learning_models.dart';
import '../domain/repositories/diagnostic_repository.dart';
import 'mock_learning_content.dart';
import 'repository_decoders.dart';

class DiagnosticApiRepository implements DiagnosticRepository {
  const DiagnosticApiRepository({required this.apiClient});

  final ApiClient apiClient;

  @override
  List<DiagnosticQuestion> get questions => mockDiagnosticQuestions;

  @override
  List<WeakLink> get weakLinks => const [
    WeakLink(title: '아직 결과를 불러오지 못했어요', body: '진단을 제출하면 약한 연결을 다시 정리해드릴게요.'),
  ];

  @override
  Future<void> selectStartingPoint(MathAreaOption mathArea) {
    return apiClient.post(
      '/api/diagnostics/starting-point',
      body: {
        'selectionType': 'WEAK_AREA',
        'mathArea': mathArea.code,
        'note': mathArea.name,
      },
      decode: (_) {},
    );
  }

  @override
  Future<DiagnosticSession> createSession() {
    return apiClient.post(
      '/api/diagnostics',
      decode: (data) {
        final object = requireObject(data);
        return DiagnosticSession(
          id: stringFromData(object['id']),
          mathArea: stringFromData(object['mathArea']),
          status: stringFromData(object['status'], fallback: 'READY'),
        );
      },
    );
  }

  @override
  Future<List<DiagnosticQuestion>> getQuestions(String diagnosticSessionId) {
    return apiClient.get(
      '/api/diagnostics/$diagnosticSessionId/questions',
      decode: (data) {
        final object = requireObject(data);
        final mathArea = stringFromData(object['mathArea']);
        final questions = object['questions'];
        if (questions is! List) {
          return const <DiagnosticQuestion>[];
        }

        return questions
            .map((questionData) {
              final question = requireObject(questionData);
              final choices = question['choices'];

              return DiagnosticQuestion(
                id: stringFromData(question['id']),
                concept: _mathAreaLabel(mathArea),
                prompt: stringFromData(question['prompt']),
                choices: choices is List
                    ? choices
                          .map((choiceData) {
                            final choice = requireObject(choiceData);
                            return AnswerChoice(
                              id: stringFromData(choice['id']),
                              label: stringFromData(choice['text']),
                            );
                          })
                          .toList(growable: false)
                    : const [],
              );
            })
            .toList(growable: false);
      },
    );
  }

  @override
  Future<DiagnosticResult> submitAnswers({
    required String diagnosticSessionId,
    required Map<String, DiagnosticAnswer> answers,
  }) {
    return apiClient.post(
      '/api/diagnostics/$diagnosticSessionId/answers',
      body: {
        'answers': answers.entries
            .map(
              (entry) => {
                'questionId': entry.key,
                'selectedChoiceId': entry.value.answerId ?? 'unknown',
              },
            )
            .toList(growable: false),
      },
      decode: diagnosticResultFromData,
    );
  }

  @override
  Future<DiagnosticResult> getResult(String diagnosticSessionId) {
    return apiClient.get(
      '/api/diagnostics/$diagnosticSessionId/result',
      decode: diagnosticResultFromData,
    );
  }

  String _mathAreaLabel(String mathArea) {
    return switch (mathArea) {
      'EQUATION' => '방정식',
      'FUNCTION' => '함수',
      'GEOMETRY' => '도형',
      'PROBABILITY_AND_STATISTICS' => '확률과 통계',
      'SEQUENCE' => '수열',
      _ => '진단 질문',
    };
  }
}

DiagnosticResult diagnosticResultFromData(Object? data) {
  final object = requireObject(data);
  final preview = objectFromData(object['nextMissionPreview']);

  return DiagnosticResult(
    diagnosticSessionId: stringFromData(object['diagnosticSessionId']),
    mathArea: stringFromData(object['mathArea']),
    status: stringFromData(object['status'], fallback: 'COMPLETED'),
    totalQuestionCount: intFromData(object['totalQuestionCount']),
    correctCount: intFromData(object['correctCount']),
    wrongCount: intFromData(object['wrongCount']),
    unknownCount: intFromData(object['unknownCount']),
    weakLinks: stringListFromData(object['weakLinks']),
    primaryRecoveryConcept: stringFromData(object['primaryRecoveryConcept']),
    summary: stringFromData(object['summary'], fallback: '다시 볼 연결을 찾았어요.'),
    nextMissionTitle: stringFromData(preview['title']),
  );
}
