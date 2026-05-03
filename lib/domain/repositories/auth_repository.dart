import '../learning_models.dart';

abstract interface class AuthRepository {
  Future<AuthProfile> signUp({
    required String loginId,
    required String email,
    required String password,
    required String nickname,
    required String mathStatus,
  });

  Future<AuthProfile> login({
    required String loginId,
    required String password,
  });

  Future<AuthProfile> verifyEmail({
    required String token,
    required String nickname,
    required String email,
  });

  Future<void> reissue();

  Future<AuthProfile> me();
}
