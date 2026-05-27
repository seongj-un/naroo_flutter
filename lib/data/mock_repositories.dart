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
  Future<EmailVerificationResendResult> resendVerificationEmail() async {
    return EmailVerificationResendResult(
      email: 'student01@example.com',
      emailVerified: false,
      nextRetryAt: DateTime.utc(2026, 5, 21, 8, 30),
    );
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
  Future<List<MathAreaOption>> getMathAreas() async {
    return const [
      MathAreaOption(
        code: 'EQUATION',
        name: '방정식',
        description: '식 정리와 등식 변형이 헷갈리는 경우',
        recommendedFor: '식을 세우거나 정리할 때 자주 막히는 학생',
        displayOrder: 1,
      ),
      MathAreaOption(
        code: 'FUNCTION',
        name: '함수',
        description: '함수와 그래프 연결이 자주 끊기는 경우',
        recommendedFor: '그래프를 읽거나 식과 연결할 때 막히는 학생',
        displayOrder: 2,
      ),
      MathAreaOption(
        code: 'GEOMETRY',
        name: '도형',
        description: '조건을 어디에 써야 할지 막막한 경우',
        recommendedFor: '도형 조건과 성질 연결이 약한 학생',
        displayOrder: 3,
      ),
    ];
  }

  @override
  Future<LearningHome> getLearningHome() async {
    return const LearningHome(
      nickname: 'student01',
      emailVerified: true,
      nextAction: LearningNextAction.startDiagnostic,
    );
  }
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

  @override
  Future<void> selectStartingPoint(MathAreaOption mathArea) async {}

  @override
  Future<DiagnosticSession> createSession() async {
    return const DiagnosticSession(
      id: 'mock-diagnostic-session',
      mathArea: 'FUNCTION',
      status: 'READY',
    );
  }

  @override
  Future<List<DiagnosticQuestion>> getQuestions(
    String diagnosticSessionId,
  ) async {
    return questions;
  }

  @override
  Future<DiagnosticResult> submitAnswers({
    required String diagnosticSessionId,
    required Map<String, DiagnosticAnswer> answers,
  }) async {
    final correctCount = questions.where((question) {
      final answer = answers[question.id];
      return answer?.answerId == question.correctAnswerId;
    }).length;
    final unknownCount = answers.values
        .where((answer) => answer.isUnknown)
        .length;
    final wrongCount = answers.length - correctCount - unknownCount;

    return DiagnosticResult(
      diagnosticSessionId: diagnosticSessionId,
      mathArea: 'FUNCTION',
      status: 'COMPLETED',
      totalQuestionCount: questions.length,
      correctCount: correctCount,
      wrongCount: wrongCount,
      unknownCount: unknownCount,
      weakLinks: const ['기울기 감각', '식과 그래프 연결', '그래프 읽기'],
      primaryRecoveryConcept: 'linear-function',
      summary: '함수 개념 연결이 약해요',
      nextMissionTitle: '함수 그래프 읽기 10분 복구',
    );
  }

  @override
  Future<DiagnosticResult> getResult(String diagnosticSessionId) {
    return submitAnswers(
      diagnosticSessionId: diagnosticSessionId,
      answers: const {},
    );
  }

  @override
  Future<void> recordQuestionShown({
    required String diagnosticSessionId,
    required DiagnosticQuestion question,
    required int questionIndex,
    String? flowVariant,
  }) async {}

  @override
  Future<void> recordAnswerSelected({
    required String diagnosticSessionId,
    required DiagnosticQuestion question,
    required DiagnosticAnswer answer,
    required int questionIndex,
    String? flowVariant,
  }) async {}

  @override
  Future<void> recordSessionAbandoned({
    required String diagnosticSessionId,
    required DiagnosticQuestion question,
    required int questionIndex,
    String? flowVariant,
  }) async {}

  @override
  Future<void> submitResultTrustFeedback({
    required String diagnosticSessionId,
    required DiagnosticResultTrustFeedbackChoice feedbackChoice,
    String? flowVariant,
    String? resultCopyVersion,
  }) async {}
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

  @override
  Future<RecoveryMission> createMission({
    required String diagnosticSessionId,
  }) async {
    return firstMission;
  }

  @override
  Future<RecoveryMission> getMission(String recoveryMissionId) async {
    return firstMission;
  }

  @override
  Future<RecoverySubmissionFeedback> submitMission({
    required String recoveryMissionId,
    required String answerText,
  }) async {
    return RecoverySubmissionFeedback(
      title: '오늘은 여기까지만 해도 충분해요.',
      message: '함수 그래프 읽기 미션을 완료했어요. 다음에는 식 변형부터 이어갈게요.',
      nextAction: nextAction(missionCompleted: true),
      mission: firstMission,
    );
  }
}
