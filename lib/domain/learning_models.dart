class AuthProfile {
  const AuthProfile({
    required this.nickname,
    required this.email,
    required this.emailVerified,
  });

  final String nickname;
  final String email;
  final bool emailVerified;
}

class WeakLink {
  const WeakLink({required this.title, required this.body});

  final String title;
  final String body;
}

class RecoveryMission {
  const RecoveryMission({
    required this.title,
    required this.estimatedTime,
    required this.explanation,
    required this.challenge,
    required this.hint,
  });

  final String title;
  final String estimatedTime;
  final String explanation;
  final String challenge;
  final String hint;
}
