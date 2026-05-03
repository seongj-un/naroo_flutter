import '../domain/diagnostic_models.dart';
import '../domain/learning_models.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/diagnostic_repository.dart';
import '../domain/repositories/learning_repository.dart';
import '../domain/repositories/recovery_repository.dart';
import 'mock_learning_content.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthProfile> signUp({
    required String loginId,
    required String email,
    required String password,
    required String nickname,
    required String mathStatus,
  }) async {
    return AuthProfile(
      nickname: nickname.isEmpty ? '나루' : nickname,
      email: email,
      emailVerified: false,
    );
  }

  @override
  Future<AuthProfile> login({
    required String loginId,
    required String password,
  }) async {
    return AuthProfile(
      nickname: loginId.isEmpty ? '나루' : loginId,
      email: '',
      emailVerified: true,
    );
  }

  @override
  Future<AuthProfile> verifyEmail({
    required String token,
    required String nickname,
    required String email,
  }) async {
    return AuthProfile(nickname: nickname, email: email, emailVerified: true);
  }

  @override
  Future<void> reissue() async {}

  @override
  Future<AuthProfile> me() async {
    return const AuthProfile(nickname: '나루', email: '', emailVerified: true);
  }
}

class MockLearningRepository implements LearningRepository {
  @override
  List<String> get mathStatusOptions => mockMathStatusOptions;

  @override
  List<String> get startingPointOptions => mockStartingPointOptions;
}

class MockDiagnosticRepository implements DiagnosticRepository {
  @override
  List<DiagnosticQuestion> get questions => mockDiagnosticQuestions;

  @override
  List<WeakLink> get weakLinks => const [
    WeakLink(title: '기울기 감각', body: 'x가 변할 때 y가 얼마나 같이 움직이는지부터 다시 보면 부담이 적어요.'),
    WeakLink(title: '식과 그래프 연결', body: '식의 숫자가 그래프에서 어디에 보이는지 연결하는 연습이 필요해요.'),
    WeakLink(title: '그래프 읽기', body: '그래프 모양을 보고 증가와 감소를 말로 바꾸는 연습부터 시작해요.'),
  ];
}

class MockRecoveryRepository implements RecoveryRepository {
  @override
  RecoveryMission get firstMission => const RecoveryMission(
    title: '함수 그래프 읽기 10분 복구',
    estimatedTime: '예상 시간 10분',
    explanation: '그래프를 볼 때는 먼저 x값이 오른쪽으로 움직일수록 y값이 위로 가는지, 아래로 가는지 확인해요.',
    challenge: 'x가 1에서 3으로 갈 때 y가 2에서 6으로 갔다면, y는 얼마나 변했나요?',
    hint: '첫 단서는 x값이 커질 때 y가 어떻게 움직이는지예요.',
  );

  @override
  String nextAction({required bool missionCompleted}) {
    return missionCompleted
        ? '다음에는 식 변형부터 이어갈게요.'
        : '함수 그래프 읽기 10분 복구를 이어갈 수 있어요.';
  }
}
