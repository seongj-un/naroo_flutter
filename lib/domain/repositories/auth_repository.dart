import '../learning_models.dart';

abstract interface class AuthRepository {
  AuthProfile signUp({required String nickname, required String email});

  AuthProfile login({required String loginId});

  AuthProfile verifyEmail({required String nickname, required String email});
}
