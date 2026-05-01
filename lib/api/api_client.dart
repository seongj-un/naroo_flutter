import '../auth/auth_store.dart';
import 'api_types.dart';

class ApiClientConfig {
  const ApiClientConfig({this.baseUrl = 'http://localhost:8080'});

  final String baseUrl;
}

abstract interface class ApiClient {
  Future<AuthSession> signUp(SignUpRequest request);

  Future<AuthSession> login(LoginRequest request);

  Future<void> verifyEmail(String token);

  Future<void> saveStartingPoint(StartingPointRequest request);
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
