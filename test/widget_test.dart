import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naroo_flutter/naroo_app.dart';

void main() {
  testWidgets('starts from the Naroo entry screen', (tester) async {
    await tester.pumpWidget(const NarooApp());

    expect(find.text('Naroo'), findsOneWidget);
    expect(find.text('수학을 다시 시작할 위치를 5분 안에 찾기'), findsOneWidget);
    expect(find.text('시작 위치 찾기'), findsOneWidget);
    expect(find.text('이미 기록이 있어요'), findsOneWidget);
  });

  testWidgets('signup flow reaches email verification', (tester) async {
    await tester.pumpWidget(const NarooApp());

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
    await tester.pumpWidget(const NarooApp());

    await _login(tester);

    expect(find.text('student01님, 오늘은 한 가지 위치만 찾으면 돼요.'), findsOneWidget);
    expect(find.text('시작 위치 고르기'), findsOneWidget);
  });

  testWidgets('starting point can be selected from learning home', (
    tester,
  ) async {
    await tester.pumpWidget(const NarooApp());

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

    expect(find.text('확인 질문을 시작할 수 있어요'), findsOneWidget);
    expect(find.text('확인 질문 시작'), findsOneWidget);
  });
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
