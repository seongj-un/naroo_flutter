import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:naroo_flutter/api/api_client.dart';
import 'package:naroo_flutter/api/api_types.dart';
import 'package:naroo_flutter/auth/auth_store.dart';
import 'package:naroo_flutter/data/auth_api_repository.dart';
import 'package:naroo_flutter/data/diagnostic_api_repository.dart';
import 'package:naroo_flutter/data/learning_api_repository.dart';
import 'package:naroo_flutter/data/recovery_api_repository.dart';
import 'package:naroo_flutter/domain/diagnostic_models.dart';

void main() {
  test('uses local backend as the default API base URL', () {
    expect(ApiClientConfig().baseUrl, 'http://localhost:8080');
  });

  test('throws ApiError when wrapped response is unsuccessful', () async {
    final client = ApiClient(
      authStore: AuthStore(),
      httpClient: MockClient((request) async {
        return http.Response(
          '{"success":false,"data":{"errorCode":"AUTH_INVALID_CREDENTIALS"}}',
          401,
        );
      }),
    );

    expect(
      () => client.post('/api/auth/login', auth: false, decode: (_) {}),
      throwsA(
        isA<ApiError>().having(
          (error) => error.errorCode,
          'errorCode',
          'AUTH_INVALID_CREDENTIALS',
        ),
      ),
    );
  });

  test('login stores access token in AuthStore', () async {
    final authStore = AuthStore();
    final client = ApiClient(
      authStore: authStore,
      httpClient: MockClient((request) async {
        return http.Response.bytes(
          utf8.encode('''
          {
            "success": true,
            "data": {
              "accessToken": "jwt-token",
              "tokenType": "Bearer",
              "expiresAt": "2026-04-30T01:00:00Z",
              "user": {
                "id": "user-id",
                "loginId": "student01",
                "emailVerified": true,
                "nickname": "나루",
                "role": "STUDENT"
              }
            }
          }
          '''),
          200,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      }),
    );
    final repository = AuthApiRepository(
      apiClient: client,
      authStore: authStore,
    );

    final profile = await repository.login(
      loginId: 'student01',
      password: 'password123',
    );

    expect(profile.nickname, '나루');
    expect(profile.emailVerified, isTrue);
    expect(authStore.accessToken, 'jwt-token');
  });

  test('reissues access token and retries authenticated requests', () async {
    final authStore = AuthStore();
    authStore.updateAccessToken('expired-token');
    final seenAuthHeaders = <String?>[];
    final client = ApiClient(
      authStore: authStore,
      httpClient: MockClient((request) async {
        if (request.url.path == '/api/auth/reissue') {
          return _jsonResponse('''
          {
            "success": true,
            "data": {
              "accessToken": "fresh-token",
              "tokenType": "Bearer",
              "expiresAt": "2026-04-30T02:00:00Z"
            }
          }
          ''');
        }

        seenAuthHeaders.add(request.headers['Authorization']);
        if (seenAuthHeaders.length == 1) {
          return _jsonResponse(
            '{"success":false,"data":{"errorCode":"GLOBAL_UNAUTHORIZED"}}',
            status: 401,
          );
        }
        return _jsonResponse(
          '{"success":true,"data":{"nickname":"나루","emailVerified":true}}',
        );
      }),
    );

    final data = await client.get('/api/auth/me', decode: (data) => data);

    expect(data, isA<Map>());
    expect(authStore.accessToken, 'fresh-token');
    expect(seenAuthHeaders, ['Bearer expired-token', 'Bearer fresh-token']);
  });

  test('learning repository decodes learning home', () async {
    final repository = LearningApiRepository(
      apiClient: ApiClient(
        authStore: AuthStore()..updateAccessToken('jwt-token'),
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/me/learning-home');
          return _jsonResponse('''
          {
            "success": true,
            "data": {
              "user": {
                "id": "user-id",
                "nickname": "나루",
                "emailVerified": true
              },
              "nextAction": "CREATE_RECOVERY_MISSION",
              "latestDiagnostic": {
                "diagnosticSessionId": "diagnostic-session-id",
                "mathArea": "FUNCTION",
                "status": "COMPLETED",
                "totalQuestionCount": 5,
                "correctCount": 2,
                "wrongCount": 2,
                "unknownCount": 1,
                "weakLinks": ["linear-function"],
                "primaryRecoveryConcept": "linear-function",
                "summary": "함수 개념 연결이 약해요"
              },
              "todayMission": null,
              "progress": {
                "completedMissionCount": 0,
                "inProgressMissionCount": 0
              }
            }
          }
          ''');
        }),
      ),
    );

    final home = await repository.getLearningHome();

    expect(home.nickname, '나루');
    expect(home.latestDiagnostic?.diagnosticSessionId, 'diagnostic-session-id');
    expect(home.latestDiagnostic?.weakLinks, ['linear-function']);
  });

  test('diagnostic repository submits starting point and answers', () async {
    final requests = <http.BaseRequest>[];
    final repository = DiagnosticApiRepository(
      apiClient: ApiClient(
        authStore: AuthStore()..updateAccessToken('jwt-token'),
        httpClient: MockClient((request) async {
          requests.add(request);

          if (request.url.path == '/api/diagnostics/starting-point') {
            expect(jsonDecode(request.body), {
              'selectionType': 'WEAK_AREA',
              'mathArea': 'FUNCTION',
              'note': '함수 그래프가 나오면 막혀요',
            });
            return _jsonResponse('{"success":true,"data":{}}');
          }

          if (request.url.path == '/api/diagnostics') {
            return _jsonResponse('''
            {
              "success": true,
              "data": {
                "id": "diagnostic-session-id",
                "mathArea": "FUNCTION",
                "status": "READY"
              }
            }
            ''');
          }

          if (request.url.path ==
              '/api/diagnostics/diagnostic-session-id/questions') {
            return _jsonResponse('''
            {
              "success": true,
              "data": {
                "diagnosticSessionId": "diagnostic-session-id",
                "mathArea": "FUNCTION",
                "status": "IN_PROGRESS",
                "questions": [
                  {
                    "id": "question-id",
                    "prompt": "문제 내용",
                    "choices": [{"id": "a", "text": "선택지 A"}]
                  }
                ]
              }
            }
            ''');
          }

          if (request.url.path ==
              '/api/diagnostics/diagnostic-session-id/answers') {
            expect(jsonDecode(request.body), {
              'answers': [
                {'questionId': 'question-id', 'selectedChoiceId': 'unknown'},
              ],
            });
            return _diagnosticResultResponse();
          }

          fail('Unexpected request: ${request.url.path}');
        }),
      ),
    );

    await repository.selectStartingPoint('함수 그래프가 나오면 막혀요');
    final session = await repository.createSession();
    final questions = await repository.getQuestions(session.id);
    final result = await repository.submitAnswers(
      diagnosticSessionId: session.id,
      answers: {'question-id': const DiagnosticAnswer.unknown()},
    );

    expect(requests.map((request) => request.url.path), [
      '/api/diagnostics/starting-point',
      '/api/diagnostics',
      '/api/diagnostics/diagnostic-session-id/questions',
      '/api/diagnostics/diagnostic-session-id/answers',
    ]);
    expect(questions.single.choices.single.label, '선택지 A');
    expect(result.primaryRecoveryConcept, 'linear-function');
  });

  test('recovery repository creates and submits mission', () async {
    final repository = RecoveryApiRepository(
      apiClient: ApiClient(
        authStore: AuthStore()..updateAccessToken('jwt-token'),
        httpClient: MockClient((request) async {
          if (request.url.path == '/api/recovery-missions') {
            expect(jsonDecode(request.body), {
              'diagnosticSessionId': 'diagnostic-session-id',
            });
            return _missionResponse();
          }

          if (request.url.path ==
              '/api/recovery-missions/mission-id/submissions') {
            expect(jsonDecode(request.body), {'answerText': '풀이 과정'});
            return _jsonResponse('''
            {
              "success": true,
              "data": {
                "id": "submission-id",
                "recoveryMissionId": "mission-id",
                "feedbackTitle": "좋아요",
                "feedbackMessage": "피드백 내용",
                "nextAction": "다음 미션으로 이어가세요",
                "submittedAt": "2026-04-30T00:00:00Z",
                "mission": {
                  "id": "mission-id",
                  "diagnosticSessionId": "diagnostic-session-id",
                  "conceptTag": "linear-function",
                  "title": "일차함수 회복 미션",
                  "prompt": "미션 설명",
                  "hints": ["힌트 1"],
                  "status": "COMPLETED",
                  "estimatedMinutes": 10,
                  "createdAt": "2026-04-30T00:00:00Z",
                  "completedAt": "2026-04-30T00:00:00Z"
                }
              }
            }
            ''');
          }

          fail('Unexpected request: ${request.url.path}');
        }),
      ),
    );

    final mission = await repository.createMission(
      diagnosticSessionId: 'diagnostic-session-id',
    );
    final feedback = await repository.submitMission(
      recoveryMissionId: mission.id,
      answerText: '풀이 과정',
    );

    expect(mission.title, '일차함수 회복 미션');
    expect(feedback.title, '좋아요');
    expect(feedback.mission.status, 'COMPLETED');
  });
}

http.Response _jsonResponse(String body, {int status = 200}) {
  return http.Response.bytes(
    utf8.encode(body),
    status,
    headers: {'Content-Type': 'application/json; charset=utf-8'},
  );
}

http.Response _diagnosticResultResponse() {
  return _jsonResponse('''
  {
    "success": true,
    "data": {
      "diagnosticSessionId": "diagnostic-session-id",
      "mathArea": "FUNCTION",
      "status": "COMPLETED",
      "totalQuestionCount": 1,
      "correctCount": 0,
      "wrongCount": 0,
      "unknownCount": 1,
      "weakLinks": ["linear-function"],
      "primaryRecoveryConcept": "linear-function",
      "summary": "함수 개념 연결이 약해요",
      "nextMissionPreview": {
        "conceptTag": "linear-function",
        "title": "일차함수 회복 미션",
        "estimatedMinutes": 10,
        "tone": "차근차근 다시 연결해보자"
      }
    }
  }
  ''');
}

http.Response _missionResponse() {
  return _jsonResponse('''
  {
    "success": true,
    "data": {
      "id": "mission-id",
      "diagnosticSessionId": "diagnostic-session-id",
      "conceptTag": "linear-function",
      "title": "일차함수 회복 미션",
      "prompt": "미션 설명",
      "hints": ["힌트 1"],
      "status": "IN_PROGRESS",
      "estimatedMinutes": 10,
      "createdAt": "2026-04-30T00:00:00Z",
      "completedAt": null
    }
  }
  ''');
}
