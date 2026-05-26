import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naroo_flutter/ui/screens/auth_screens.dart';

void main() {
  testWidgets('login does not submit blank credentials', (tester) async {
    // Regression: ISSUE-001 — blank login hit the API and showed a server error
    // Found by /qa on 2026-05-26
    // Report: .gstack/qa-reports/qa-report-localhost-2026-05-26.md
    var loginCalls = 0;

    await tester.pumpWidget(
      _wrap(
        AuthScreen(
          mode: AuthMode.login,
          mathStatusOptions: const ['아직 모르겠어요'],
          isLoading: false,
          errorMessage: null,
          statusMessage: null,
          onModeChanged: (_) {},
          onBack: () {},
          onSignup: ({
            required loginId,
            required email,
            required password,
            required nickname,
            required mathStatus,
          }) async {},
          onLogin: ({required loginId, required password}) async {
            loginCalls += 1;
          },
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, '기록 불러오기'));
    await tester.pump();

    expect(loginCalls, 0);
    expect(find.text('아이디와 비밀번호를 입력해 주세요.'), findsOneWidget);
  });

  testWidgets('signup does not submit blank required fields', (tester) async {
    // Regression: ISSUE-001 — blank signup hit the API and showed a server error
    // Found by /qa on 2026-05-26
    // Report: .gstack/qa-reports/qa-report-localhost-2026-05-26.md
    var signupCalls = 0;

    await tester.pumpWidget(
      _wrap(
        AuthScreen(
          mode: AuthMode.signup,
          mathStatusOptions: const ['수업을 따라가고 있어요', '아직 모르겠어요'],
          isLoading: false,
          errorMessage: null,
          statusMessage: null,
          onModeChanged: (_) {},
          onBack: () {},
          onSignup: ({
            required loginId,
            required email,
            required password,
            required nickname,
            required mathStatus,
          }) async {
            signupCalls += 1;
          },
          onLogin: ({required loginId, required password}) async {},
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.widgetWithText(ElevatedButton, '내 기록 만들기'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(ElevatedButton, '내 기록 만들기'));
    await tester.pump();

    expect(signupCalls, 0);
    expect(
      find.text('아이디, 이메일, 비밀번호, 닉네임을 모두 입력해 주세요.'),
      findsOneWidget,
    );
  });

  testWidgets('email verification does not submit a blank code', (
    tester,
  ) async {
    // Regression: ISSUE-002 — blank verification code hit the API as invalid token
    // Found by /qa on 2026-05-26
    // Report: .gstack/qa-reports/qa-report-localhost-2026-05-26.md
    var verifyCalls = 0;

    await tester.pumpWidget(
      _wrap(
        EmailVerificationScreen(
          email: 'student01@example.com',
          isLoading: false,
          isLinkFlow: false,
          showLinkFailureState: false,
          showResendAction: false,
          isResendCoolingDown: false,
          resendCooldownMessage: null,
          errorMessage: null,
          statusMessage: null,
          onVerify: (token) async {
            verifyCalls += 1;
          },
          onResend: () async {},
          onUseCodeInstead: () {},
          onBackToLogin: () {},
          onLater: () {},
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, '인증 완료하기'));
    await tester.pump();

    expect(verifyCalls, 0);
    expect(find.text('인증 코드를 입력해 주세요.'), findsOneWidget);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    home: child,
    theme: ThemeData(useMaterial3: true),
  );
}
