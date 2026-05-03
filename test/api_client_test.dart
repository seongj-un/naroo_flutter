import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:naroo_flutter/api/api_client.dart';
import 'package:naroo_flutter/api/api_types.dart';
import 'package:naroo_flutter/auth/auth_store.dart';
import 'package:naroo_flutter/data/auth_api_repository.dart';

void main() {
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
}
