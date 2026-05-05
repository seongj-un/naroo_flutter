import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_store.dart';
import 'api_types.dart';

class ApiClientConfig {
  const ApiClientConfig({this.baseUrl = 'http://localhost:8080'});

  final String baseUrl;
}

class ApiClient {
  ApiClient({
    required this.authStore,
    this.config = const ApiClientConfig(),
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final ApiClientConfig config;
  final AuthStore authStore;
  final http.Client _httpClient;

  Future<T> get<T>(
    String path, {
    required T Function(Object? data) decode,
    bool auth = true,
  }) {
    return _request('GET', path, decode: decode, auth: auth);
  }

  Future<T> post<T>(
    String path, {
    JsonMap? body,
    required T Function(Object? data) decode,
    bool auth = true,
  }) {
    return _request('POST', path, body: body, decode: decode, auth: auth);
  }

  Future<T> _request<T>(
    String method,
    String path, {
    JsonMap? body,
    required T Function(Object? data) decode,
    required bool auth,
    bool retryOnUnauthorized = true,
  }) async {
    final uri = Uri.parse('${config.baseUrl}$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (auth && authStore.accessToken != null)
        'Authorization': 'Bearer ${authStore.accessToken}',
    };

    final response = switch (method) {
      'GET' => await _httpClient.get(uri, headers: headers),
      'POST' => await _httpClient.post(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      ),
      _ => throw StateError('Unsupported method: $method'),
    };

    if (auth &&
        retryOnUnauthorized &&
        response.statusCode == 401 &&
        await _tryReissueAccessToken()) {
      return _request(
        method,
        path,
        body: body,
        decode: decode,
        auth: auth,
        retryOnUnauthorized: false,
      );
    }

    return _decodeWrappedResponse(response, decode);
  }

  Future<bool> _tryReissueAccessToken() async {
    try {
      final accessToken = await _request(
        'POST',
        '/api/auth/reissue',
        decode: (data) {
          final object = _requireObject(data);
          final accessToken = object['accessToken'];
          if (accessToken is String) {
            return accessToken;
          }
          throw const ApiError(
            status: 200,
            errorCode: 'AUTH_ACCESS_TOKEN_MISSING',
          );
        },
        auth: false,
        retryOnUnauthorized: false,
      );
      authStore.updateAccessToken(accessToken);
      return true;
    } catch (_) {
      authStore.clear();
      return false;
    }
  }

  T _decodeWrappedResponse<T>(
    http.Response response,
    T Function(Object? data) decode,
  ) {
    final payload = _decodeJsonObject(response);
    final success = payload['success'];
    final data = payload['data'];

    if (success == true &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      return decode(data);
    }

    throw ApiError(
      status: response.statusCode,
      errorCode: _extractErrorCode(data) ?? 'GLOBAL_BAD_RESPONSE',
    );
  }

  JsonMap _decodeJsonObject(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } on FormatException {
      throw ApiError(
        status: response.statusCode,
        errorCode: 'GLOBAL_BAD_RESPONSE',
      );
    }

    throw ApiError(
      status: response.statusCode,
      errorCode: 'GLOBAL_BAD_RESPONSE',
    );
  }

  String? _extractErrorCode(Object? data) {
    if (data is Map) {
      final errorCode = data['errorCode'];
      if (errorCode is String) {
        return errorCode;
      }
    }
    return null;
  }

  JsonMap _requireObject(Object? data) {
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    throw const ApiError(status: 200, errorCode: 'GLOBAL_BAD_RESPONSE');
  }
}

class SignUpRequest {
  const SignUpRequest({
    required this.loginId,
    required this.email,
    required this.password,
    required this.nickname,
    required this.mathStatus,
  });

  final String loginId;
  final String email;
  final String password;
  final String nickname;
  final String mathStatus;

  JsonMap toJson() => {
    'loginId': loginId,
    'email': email,
    'password': password,
    'nickname': nickname,
    'mathStatus': mathStatus,
  };
}

class LoginRequest {
  const LoginRequest({required this.loginId, required this.password});

  final String loginId;
  final String password;

  JsonMap toJson() => {'loginId': loginId, 'password': password};
}

class StartingPointRequest {
  const StartingPointRequest({
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
