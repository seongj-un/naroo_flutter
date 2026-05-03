class AuthUser {
  const AuthUser({
    required this.id,
    required this.loginId,
    required this.nickname,
    required this.role,
    required this.emailVerified,
  });

  final String id;
  final String loginId;
  final String nickname;
  final String role;
  final bool emailVerified;

  bool get isAdmin => role == 'ADMIN';
}

class AuthSession {
  const AuthSession({required this.accessToken, required this.user});

  final String accessToken;
  final AuthUser user;
}

class AuthStore {
  AuthSession? _session;

  String? get accessToken => _session?.accessToken;
  AuthUser? get user => _session?.user;
  bool get isAuthenticated => _session != null;
  bool get isAdmin => _session?.user.isAdmin ?? false;

  void setSession(AuthSession session) {
    _session = session;
  }

  void updateAccessToken(String accessToken) {
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }
    _session = AuthSession(accessToken: accessToken, user: currentSession.user);
  }

  void clear() {
    _session = null;
  }
}
