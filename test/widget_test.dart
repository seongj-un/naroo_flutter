import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naroo_flutter/app/naroo_dependencies.dart';
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

    await tester.tap(find.text('함수 그래프가 나오면 막혀요'));
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
    expect(find.text('완료한 미션 1개'), findsOneWidget);
  });
}

Widget _mockApp() {
  return NarooApp(dependencies: NarooDependencies.mock());
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
