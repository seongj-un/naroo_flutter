import 'package:flutter/material.dart';

class NarooApp extends StatelessWidget {
  const NarooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naroo',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const NarooShell(),
    );
  }
}

ThemeData _buildTheme() {
  const background = Color(0xFFFAF8F3);
  const surface = Color(0xFFFFFFFF);
  const text = Color(0xFF24231F);
  const muted = Color(0xFF6E6A61);
  const accent = Color(0xFF2E7565);
  const border = Color(0xFFE0DCD2);

  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
        surface: surface,
      ).copyWith(
        primary: accent,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: text,
        outline: border,
      );

  final baseTextTheme = Typography.blackMountainView;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    fontFamily: 'Pretendard',
    fontFamilyFallback: const ['SUIT', 'Noto Sans KR', 'Apple SD Gothic Neo'],
    textTheme: baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: text,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: text,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: text,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.35,
        letterSpacing: 0,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: text,
        fontSize: 16,
        height: 1.55,
        letterSpacing: 0,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: muted,
        fontSize: 14,
        height: 1.5,
        letterSpacing: 0,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB8564E)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        elevation: 0,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: text,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        minimumSize: const Size(44, 44),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    ),
  );
}

enum _Stage { entry, auth, emailVerification, home, startingPoint }

enum _AuthMode { signup, login }

class NarooShell extends StatefulWidget {
  const NarooShell({super.key});

  @override
  State<NarooShell> createState() => _NarooShellState();
}

class _NarooShellState extends State<NarooShell> {
  _Stage _stage = _Stage.entry;
  _AuthMode _authMode = _AuthMode.signup;
  String _nickname = '나루';
  String _email = '';
  String? _startingPoint;
  bool _emailVerified = false;

  void _openAuth(_AuthMode mode) {
    setState(() {
      _authMode = mode;
      _stage = _Stage.auth;
    });
  }

  void _submitSignup({required String nickname, required String email}) {
    setState(() {
      _nickname = nickname.isEmpty ? '나루' : nickname;
      _email = email;
      _emailVerified = false;
      _stage = _Stage.emailVerification;
    });
  }

  void _submitLogin({required String loginId}) {
    setState(() {
      _nickname = loginId.isEmpty ? '나루' : loginId;
      _emailVerified = true;
      _stage = _Stage.home;
    });
  }

  void _completeVerification() {
    setState(() {
      _emailVerified = true;
      _stage = _Stage.home;
    });
  }

  void _skipVerificationForNow() {
    setState(() => _stage = _Stage.home);
  }

  @override
  Widget build(BuildContext context) {
    final child = switch (_stage) {
      _Stage.entry => _EntryScreen(
        onStart: () => _openAuth(_AuthMode.signup),
        onExistingRecord: () => _openAuth(_AuthMode.login),
      ),
      _Stage.auth => _AuthScreen(
        mode: _authMode,
        onModeChanged: (mode) => setState(() => _authMode = mode),
        onBack: () => setState(() => _stage = _Stage.entry),
        onSignup: _submitSignup,
        onLogin: _submitLogin,
      ),
      _Stage.emailVerification => _EmailVerificationScreen(
        email: _email,
        onVerify: _completeVerification,
        onLater: _skipVerificationForNow,
      ),
      _Stage.home => _LearningHomeScreen(
        nickname: _nickname,
        emailVerified: _emailVerified,
        startingPoint: _startingPoint,
        onVerifyEmail: () => setState(() => _stage = _Stage.emailVerification),
        onStartDiagnostic: () => setState(() => _stage = _Stage.startingPoint),
      ),
      _Stage.startingPoint => _StartingPointScreen(
        selectedStartingPoint: _startingPoint,
        onBack: () => setState(() => _stage = _Stage.home),
        onSubmit: (startingPoint) {
          setState(() {
            _startingPoint = startingPoint;
            _stage = _Stage.home;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('확인 질문으로 이동할 준비가 됐어요.')));
        },
      ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: child,
    );
  }
}

class _EntryScreen extends StatelessWidget {
  const _EntryScreen({required this.onStart, required this.onExistingRecord});

  final VoidCallback onStart;
  final VoidCallback onExistingRecord;

  @override
  Widget build(BuildContext context) {
    return _NarooPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandHeader(),
          const Spacer(),
          Text(
            '수학을 다시 시작할 위치를 5분 안에 찾기',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Text(
            '점수 매기지 않음. 틀려도 계속 진행됨.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: onStart, child: const Text('시작 위치 찾기')),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onExistingRecord,
            child: const Text('이미 기록이 있어요'),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _AuthScreen extends StatefulWidget {
  const _AuthScreen({
    required this.mode,
    required this.onModeChanged,
    required this.onBack,
    required this.onSignup,
    required this.onLogin,
  });

  final _AuthMode mode;
  final ValueChanged<_AuthMode> onModeChanged;
  final VoidCallback onBack;
  final void Function({required String nickname, required String email})
  onSignup;
  final void Function({required String loginId}) onLogin;

  @override
  State<_AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<_AuthScreen> {
  final _loginIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  String _mathStatus = _mathStatuses.last;

  static const _mathStatuses = [
    '수업을 따라가고 있어요',
    '간신히 따라가고 있어요',
    '거의 놓친 것 같아요',
    '아직 모르겠어요',
  ];

  @override
  void dispose() {
    _loginIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSignup = widget.mode == _AuthMode.signup;

    return _NarooPage(
      child: ListView(
        children: [
          _TopBar(onBack: widget.onBack),
          const SizedBox(height: 24),
          Text(
            isSignup ? '가벼운 학습 기록 만들기' : '기록 불러오기',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '친구에게 보여줄 점수표를 만들지 않아요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _ModeSwitch(mode: widget.mode, onChanged: widget.onModeChanged),
          const SizedBox(height: 24),
          _NarooTextField(
            controller: _loginIdController,
            label: 'Login ID',
            textInputAction: TextInputAction.next,
          ),
          if (isSignup) ...[
            const SizedBox(height: 12),
            _NarooTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
          ],
          const SizedBox(height: 12),
          _NarooTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: true,
            textInputAction: isSignup
                ? TextInputAction.next
                : TextInputAction.done,
          ),
          if (isSignup) ...[
            const SizedBox(height: 12),
            _NarooTextField(
              controller: _nicknameController,
              label: 'Nickname',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Text('요즘 수학 상태', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final status in _mathStatuses)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ChoiceRow(
                  label: status,
                  selected: _mathStatus == status,
                  onTap: () => setState(() => _mathStatus = status),
                ),
              ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (isSignup) {
                widget.onSignup(
                  nickname: _nicknameController.text.trim(),
                  email: _emailController.text.trim(),
                );
                return;
              }
              widget.onLogin(loginId: _loginIdController.text.trim());
            },
            child: Text(isSignup ? '내 기록 만들기' : '기록 불러오기'),
          ),
        ],
      ),
    );
  }
}

class _EmailVerificationScreen extends StatefulWidget {
  const _EmailVerificationScreen({
    required this.email,
    required this.onVerify,
    required this.onLater,
  });

  final String email;
  final VoidCallback onVerify;
  final VoidCallback onLater;

  @override
  State<_EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<_EmailVerificationScreen> {
  final _tokenController = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email.isEmpty ? '가입한 이메일' : widget.email;

    return _NarooPage(
      child: ListView(
        children: [
          const _BrandHeader(),
          const SizedBox(height: 48),
          Text(
            '이메일 확인이 필요해요',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            '$email 기록을 안전하게 저장하려면 이메일 인증을 먼저 완료해야 해요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _NarooTextField(
            controller: _tokenController,
            label: '인증 코드',
            textInputAction: TextInputAction.done,
          ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(_message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() => _message = '인증을 확인하는 중...');
              widget.onVerify();
            },
            child: const Text('인증 완료하기'),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: widget.onLater, child: const Text('나중에 다시 시도')),
        ],
      ),
    );
  }
}

class _LearningHomeScreen extends StatelessWidget {
  const _LearningHomeScreen({
    required this.nickname,
    required this.emailVerified,
    required this.startingPoint,
    required this.onVerifyEmail,
    required this.onStartDiagnostic,
  });

  final String nickname;
  final bool emailVerified;
  final String? startingPoint;
  final VoidCallback onVerifyEmail;
  final VoidCallback onStartDiagnostic;

  @override
  Widget build(BuildContext context) {
    final hasStartingPoint = startingPoint != null;

    return _NarooPage(
      child: ListView(
        children: [
          const _BrandHeader(),
          const SizedBox(height: 32),
          Text(
            '$nickname님, 오늘은 한 가지 위치만 찾으면 돼요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          _ActionPanel(
            title: !emailVerified
                ? '이메일 확인이 필요해요'
                : hasStartingPoint
                ? '확인 질문을 시작할 수 있어요'
                : '첫 진단을 시작할 수 있어요',
            body: !emailVerified
                ? '기록을 안전하게 저장한 뒤 시작 위치를 이어갈 수 있어요.'
                : hasStartingPoint
                ? '$startingPoint 쪽에서 가볍게 확인해 볼게요. 아직 점수는 만들지 않아요.'
                : '아직 첫 기록이 없어요. 요즘 가장 막히는 곳부터 가볍게 확인해 볼게요.',
            buttonLabel: !emailVerified
                ? '이메일 인증하기'
                : hasStartingPoint
                ? '확인 질문 시작'
                : '시작 위치 고르기',
            onPressed: emailVerified ? onStartDiagnostic : onVerifyEmail,
          ),
          const SizedBox(height: 16),
          _ProgressLine(
            label: emailVerified ? '다음 행동을 찾았어요' : '인증 후 다음 행동을 찾을게요',
          ),
        ],
      ),
    );
  }
}

class _StartingPointScreen extends StatefulWidget {
  const _StartingPointScreen({
    required this.selectedStartingPoint,
    required this.onBack,
    required this.onSubmit,
  });

  final String? selectedStartingPoint;
  final VoidCallback onBack;
  final ValueChanged<String> onSubmit;

  @override
  State<_StartingPointScreen> createState() => _StartingPointScreenState();
}

class _StartingPointScreenState extends State<_StartingPointScreen> {
  late String? _selected = widget.selectedStartingPoint;

  static const _startingPoints = [
    '식을 어떻게 바꿀지 모르겠어요',
    '함수 그래프가 나오면 막혀요',
    '도형 조건을 어디에 써야 할지 모르겠어요',
    '확률과 통계에서 기준을 못 잡겠어요',
    '수열 규칙을 식으로 못 바꾸겠어요',
    '어디서부터 다시 해야 할지 모르겠어요',
  ];

  @override
  Widget build(BuildContext context) {
    return _NarooPage(
      child: ListView(
        children: [
          _TopBar(onBack: widget.onBack),
          const SizedBox(height: 24),
          Text(
            '요즘 수학에서 어디가 제일 막히나요?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '정확히 몰라도 괜찮아요. 지금 가장 가까운 문장을 고르면 돼요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          for (final startingPoint in _startingPoints)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ChoiceRow(
                label: startingPoint,
                selected: _selected == startingPoint,
                onTap: () => setState(() => _selected = startingPoint),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selected == null
                ? null
                : () => widget.onSubmit(_selected!),
            child: const Text('가볍게 확인하기'),
          ),
        ],
      ),
    );
  }
}

class _NarooPage extends StatelessWidget {
  const _NarooPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        'Naroo',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: '돌아가기',
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 8),
        const _BrandHeader(),
      ],
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.onChanged});

  final _AuthMode mode;
  final ValueChanged<_AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_AuthMode>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: _AuthMode.signup, label: Text('Signup')),
        ButtonSegment(value: _AuthMode.login, label: Text('Login')),
      ],
      selected: {mode},
      onSelectionChanged: (value) => onChanged(value.first),
    );
  }
}

class _NarooTextField extends StatelessWidget {
  const _NarooTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected ? const Color(0xFFE7F0EC) : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? colors.primary : colors.outline,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? colors.primary : const Color(0xFF8B867A),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outline),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onPressed, child: Text(buttonLabel)),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.bookmark_added_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
