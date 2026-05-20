import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naroo_flutter/app/naroo_dependencies.dart';
import 'package:naroo_flutter/data/mock_repositories.dart';
import 'package:naroo_flutter/domain/learning_models.dart';
import 'package:naroo_flutter/domain/repositories/recovery_repository.dart';
import 'package:naroo_flutter/domain/repositories/learning_repository.dart';
import 'package:naroo_flutter/naroo_app.dart';

void main() {
  testWidgets('starts from the Naroo entry screen', (tester) async {
    await tester.pumpWidget(_mockApp());

    expect(find.text('Naroo'), findsOneWidget);
    expect(find.text('수학을 다시 시작할 위치를 5분 안에 찾기'), findsOneWidget);
    expect(find.text('시작 위치 찾기'), findsOneWidget);
    expect(find.text('이미 기록이 있어요'), findsOneWidget);
  });

  testWidgets('signup flow reaches email verification', (tester) async {
    await tester.pumpWidget(_mockApp());

    await tester.tap(find.text('시작 위치 찾기'));
    await tester.pumpAndSettle();

    expect(find.text('가벼운 학습 기록 만들기'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Login ID'),
      'student01',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'student01@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password123',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Nickname'), '나루');
    await tester.scrollUntilVisible(
      find.text('내 기록 만들기'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('내 기록 만들기'));
    await tester.pumpAndSettle();

    expect(find.text('이메일 확인이 필요해요'), findsOneWidget);
    expect(find.text('인증 완료하기'), findsOneWidget);
  });

  testWidgets('login flow reaches learning home', (tester) async {
    await tester.pumpWidget(_mockApp());

    await _login(tester);

    expect(find.text('student01님, 오늘은 한 가지 위치만 찾으면 돼요.'), findsOneWidget);
    expect(find.text('시작 위치 고르기'), findsOneWidget);
    expect(find.text('저장된 기록 보기'), findsOneWidget);
  });

  testWidgets('student can complete the mock diagnostic and recovery loop', (
    tester,
  ) async {
    await _setTallPhoneViewport(tester);
    await tester.pumpWidget(_mockApp());

    await _login(tester);
    await tester.tap(find.text('시작 위치 고르기'));
    await tester.pumpAndSettle();

    expect(find.text('요즘 수학에서 어디가 제일 막히나요?'), findsOneWidget);

    await tester.tap(find.text('함수'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('가볍게 확인하기'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('가볍게 확인하기'));
    await tester.pumpAndSettle();

    expect(find.text('함수 그래프 읽기'), findsOneWidget);

    await _scrollToText(tester, '일차함수처럼 일정하게 증가해요');
    await tester.tap(
      find.ancestor(
        of: find.text('일차함수처럼 일정하게 증가해요'),
        matching: find.byType(InkWell),
      ),
    );
    await tester.pumpAndSettle();
    await _scrollToText(tester, '다음 문항');
    await tester.tap(find.widgetWithText(ElevatedButton, '다음 문항'));
    await tester.pumpAndSettle();

    expect(find.text('기울기 감각'), findsOneWidget);

    await _scrollToText(tester, '잘 모르겠어요');
    await tester.tap(
      find.ancestor(of: find.text('잘 모르겠어요'), matching: find.byType(InkWell)),
    );
    await tester.pumpAndSettle();
    await _scrollToText(tester, '다음 문항');
    await tester.tap(find.widgetWithText(ElevatedButton, '다음 문항'));
    await tester.pumpAndSettle();

    expect(find.text('식과 그래프 연결'), findsOneWidget);

    await _scrollToText(tester, '1을 지나요');
    await tester.tap(
      find.ancestor(of: find.text('1을 지나요'), matching: find.byType(InkWell)),
    );
    await tester.pumpAndSettle();
    await _scrollToText(tester, '결과 보기');
    await tester.tap(find.widgetWithText(ElevatedButton, '결과 보기'));
    await tester.pumpAndSettle();

    expect(find.text('약한 연결'), findsOneWidget);
    expect(find.text('첫 10분 복습 시작'), findsOneWidget);

    await tester.tap(find.text('첫 10분 복습 시작'));
    await tester.pumpAndSettle();

    expect(find.text('함수 그래프 읽기 10분 복구'), findsOneWidget);

    await tester.tap(find.text('힌트 보기'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '내 답 적기'), '4');
    await _scrollToText(tester, '미션 제출하기');
    await tester.tap(find.widgetWithText(ElevatedButton, '미션 제출하기'));
    await tester.pumpAndSettle();

    expect(find.text('오늘은 여기까지만 해도 충분해요.'), findsOneWidget);

    await tester.tap(find.text('저장된 기록 보기'));
    await tester.pumpAndSettle();

    expect(find.text('마지막 위치를 저장해뒀어요.'), findsOneWidget);
    expect(find.text('저장된 학습 상태를 확인했어요'), findsOneWidget);
  });

  testWidgets(
    'completed recovery mission returns feedback instead of reopening mission form',
    (tester) async {
      await _setTallPhoneViewport(tester);
      await tester.pumpWidget(_completedMissionApp());

      await _login(tester);
      await tester.tap(find.text('시작 위치 고르기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('함수'));
      await tester.pumpAndSettle();
      await _scrollToText(tester, '가볍게 확인하기');
      await tester.tap(find.text('가볍게 확인하기'));
      await tester.pumpAndSettle();

      await _scrollToText(tester, '일차함수처럼 일정하게 증가해요');
      await tester.tap(
        find.ancestor(
          of: find.text('일차함수처럼 일정하게 증가해요'),
          matching: find.byType(InkWell),
        ),
      );
      await tester.pumpAndSettle();
      await _scrollToText(tester, '다음 문항');
      await tester.tap(find.widgetWithText(ElevatedButton, '다음 문항'));
      await tester.pumpAndSettle();

      await _scrollToText(tester, '잘 모르겠어요');
      await tester.tap(
        find.ancestor(of: find.text('잘 모르겠어요'), matching: find.byType(InkWell)),
      );
      await tester.pumpAndSettle();
      await _scrollToText(tester, '다음 문항');
      await tester.tap(find.widgetWithText(ElevatedButton, '다음 문항'));
      await tester.pumpAndSettle();

      await _scrollToText(tester, '1을 지나요');
      await tester.tap(
        find.ancestor(of: find.text('1을 지나요'), matching: find.byType(InkWell)),
      );
      await tester.pumpAndSettle();
      await _scrollToText(tester, '결과 보기');
      await tester.tap(find.widgetWithText(ElevatedButton, '결과 보기'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('첫 10분 복습 시작'));
      await tester.pumpAndSettle();

      expect(find.text('오늘 미션은 이미 완료됐어요.'), findsOneWidget);
      expect(find.text('학습 홈으로 돌아가서 다음 상태를 확인해 주세요.'), findsOneWidget);
    },
  );

  testWidgets(
    'home opens saved progress when recovery series is completed',
    (tester) async {
      await tester.pumpWidget(_nextMissionHomeApp());

      await _login(tester);

      expect(find.text('저장된 기록 보기'), findsNWidgets(2));
      await tester.tap(find.text('저장된 기록 보기').first);
      await tester.pumpAndSettle();

      expect(find.text('마지막 위치를 저장해뒀어요.'), findsOneWidget);
      expect(find.text('최근 회복 미션을 모두 완료했어요. 저장된 기록을 확인해 주세요.'), findsOneWidget);
    },
  );
}

Widget _mockApp() {
  return NarooApp(dependencies: NarooDependencies.mock());
}

Widget _completedMissionApp() {
  return NarooApp(
    dependencies: NarooDependencies(
      authRepository: MockAuthRepository(),
      learningRepository: MockLearningRepository(),
      diagnosticRepository: MockDiagnosticRepository(),
      recoveryRepository: _CompletedMissionRecoveryRepository(),
    ),
  );
}

Widget _nextMissionHomeApp() {
  return NarooApp(
    dependencies: NarooDependencies(
      authRepository: MockAuthRepository(),
      learningRepository: _NextMissionLearningRepository(),
      diagnosticRepository: MockDiagnosticRepository(),
      recoveryRepository: MockRecoveryRepository(),
    ),
  );
}

Future<void> _scrollToText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    300,
    scrollable: find.byType(Scrollable).first,
  );
}

Future<void> _setTallPhoneViewport(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 1000);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _login(WidgetTester tester) async {
  await tester.tap(find.text('이미 기록이 있어요'));
  await tester.pumpAndSettle();

  expect(find.text('기록 불러오기'), findsNWidgets(2));

  await tester.enterText(
    find.widgetWithText(TextField, 'Login ID'),
    'student01',
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Password'),
    'password123',
  );
  await tester.tap(find.text('기록 불러오기').last);
  await tester.pumpAndSettle();
}

class _CompletedMissionRecoveryRepository implements RecoveryRepository {
  @override
  RecoveryMission get firstMission => const RecoveryMission(
    id: 'completed-mission',
    diagnosticSessionId: 'mock-diagnostic-session',
    title: '이미 완료된 함수 미션',
    estimatedTime: '예상 시간 10분',
    explanation: '이 미션은 이미 끝난 상태로 돌아왔어요.',
    challenge: '다음 상태만 확인하면 돼요.',
    hint: '학습 홈으로 돌아가세요.',
    status: 'COMPLETED',
  );

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
  String nextAction({required bool missionCompleted}) {
    return '학습 홈에서 다음 행동을 확인해 주세요.';
  }

  @override
  Future<RecoverySubmissionFeedback> submitMission({
    required String recoveryMissionId,
    required String answerText,
  }) {
    throw UnimplementedError();
  }
}

class _NextMissionLearningRepository implements LearningRepository {
  @override
  List<String> get mathStatusOptions => MockLearningRepository().mathStatusOptions;

  @override
  Future<List<MathAreaOption>> getMathAreas() {
    return MockLearningRepository().getMathAreas();
  }

  @override
  Future<LearningHome> getLearningHome() async {
    return const LearningHome(
      nickname: 'student01',
      emailVerified: true,
      nextAction: LearningNextAction.recoverySeriesCompleted,
      latestDiagnostic: LearningDiagnosticSummary(
        diagnosticSessionId: 'diagnostic-1',
        mathArea: 'FUNCTION',
        status: 'COMPLETED',
        totalQuestionCount: 2,
        correctCount: 1,
        wrongCount: 0,
        unknownCount: 1,
        weakLinks: ['function_substitution'],
        primaryRecoveryConcept: 'function_substitution',
        summary: '다음 미션으로 이어가면 돼요.',
      ),
      todayMission: null,
      latestMission: RecoveryMission(
        id: 'completed-mission',
        diagnosticSessionId: 'diagnostic-1',
        title: '함수값 대입 10분 복구 미션',
        estimatedTime: '예상 시간 10분',
        explanation: '최근 미션을 완료했어요.',
        challenge: '완료한 미션입니다.',
        hint: '저장된 기록을 확인해 보세요.',
        status: 'COMPLETED',
      ),
      completedMissionCount: 1,
      inProgressMissionCount: 0,
    );
  }
}
