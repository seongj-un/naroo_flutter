import '../api/api_client.dart';
import '../api/api_types.dart';
import '../auth/auth_store.dart';
import '../domain/learning_models.dart';
import '../domain/repositories/auth_repository.dart';

class AuthApiRepository implements AuthRepository {
  const AuthApiRepository({required this.apiClient, required this.authStore});

  final ApiClient apiClient;
  final AuthStore authStore;

  @override
  Future<AuthProfile> signUp({
    required String loginId,
    required String email,
    required String password,
    required String nickname,
    required String mathStatus,
  }) {
    return apiClient.post(
      '/api/auth/sign-up',
      auth: false,
      body: SignUpRequest(
        loginId: loginId,
        email: email,
        password: password,
        nickname: nickname,
        mathStatus: _toMathStatusCode(mathStatus),
      ).toJson(),
      decode: _profileFromData,
    );
  }

  @override
  Future<AuthProfile> login({
    required String loginId,
    required String password,
  }) async {
    final session = await apiClient.post(
      '/api/auth/login',
      auth: false,
      body: LoginRequest(loginId: loginId, password: password).toJson(),
      decode: _sessionFromData,
    );
    authStore.setSession(session);
    return _profileFromUser(session.user);
  }

  @override
  Future<AuthProfile> verifyEmail({
    required String token,
    required String nickname,
    required String email,
  }) async {
    final verifiedEmail = await apiClient.post(
      '/api/auth/email/verify',
      auth: false,
      body: {'token': token},
      decode: (data) {
        final object = _requireObject(data);
        return object['email'] as String? ?? email;
      },
    );

    return AuthProfile(
      nickname: nickname,
      email: verifiedEmail,
      emailVerified: true,
    );
  }

  @override
  Future<void> reissue() async {
    final accessToken = await apiClient.post(
      '/api/auth/reissue',
      auth: false,
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
    );
    authStore.updateAccessToken(accessToken);
  }

  @override
  Future<AuthProfile> me() {
    return apiClient.get('/api/auth/me', decode: _profileFromData);
  }

  AuthSession _sessionFromData(Object? data) {
    final object = _requireObject(data);
    final accessToken = object['accessToken'];
    final userData = object['user'];

    if (accessToken is! String) {
      throw const ApiError(status: 200, errorCode: 'AUTH_ACCESS_TOKEN_MISSING');
    }

    return AuthSession(accessToken: accessToken, user: _userFromData(userData));
  }

  AuthUser _userFromData(Object? data) {
    final object = _requireObject(data);
    final id = object['id'];
    final loginId = object['loginId'];
    final nickname = object['nickname'];
    final role = object['role'];
    final emailVerified = object['emailVerified'];

    return AuthUser(
      id: id?.toString() ?? '',
      loginId: loginId is String ? loginId : '',
      nickname: nickname is String ? nickname : '나루',
      role: role is String ? role : 'STUDENT',
      emailVerified: emailVerified == true,
    );
  }

  AuthProfile _profileFromData(Object? data) {
    final object = _requireObject(data);
    final nickname = object['nickname'];
    final email = object['email'];
    final emailVerified = object['emailVerified'];

    return AuthProfile(
      nickname: nickname is String ? nickname : '나루',
      email: email is String ? email : '',
      emailVerified: emailVerified == true,
    );
  }

  AuthProfile _profileFromUser(AuthUser user) {
    return AuthProfile(
      nickname: user.nickname,
      email: '',
      emailVerified: user.emailVerified,
    );
  }

  JsonMap _requireObject(Object? data) {
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    throw const ApiError(status: 200, errorCode: 'GLOBAL_BAD_RESPONSE');
  }

  String _toMathStatusCode(String mathStatus) {
    return switch (mathStatus) {
      '수업을 따라가고 있어요' => 'FOLLOWS_CLASS',
      '간신히 따라가고 있어요' => 'BARELY_FOLLOWS',
      '거의 놓친 것 같아요' => 'MOSTLY_GAVE_UP',
      _ => 'UNKNOWN',
    };
  }
}
