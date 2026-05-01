import 'package:flutter/material.dart';

import '../common/naroo_widgets.dart';

enum AuthMode { signup, login }

class EntryScreen extends StatelessWidget {
  const EntryScreen({
    super.key,
    required this.onStart,
    required this.onExistingRecord,
  });

  final VoidCallback onStart;
  final VoidCallback onExistingRecord;

  @override
  Widget build(BuildContext context) {
    return NarooPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandHeader(),
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

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.mode,
    required this.mathStatusOptions,
    required this.onModeChanged,
    required this.onBack,
    required this.onSignup,
    required this.onLogin,
  });

  final AuthMode mode;
  final List<String> mathStatusOptions;
  final ValueChanged<AuthMode> onModeChanged;
  final VoidCallback onBack;
  final void Function({required String nickname, required String email})
  onSignup;
  final void Function({required String loginId}) onLogin;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  late String _mathStatus = widget.mathStatusOptions.last;

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
    final isSignup = widget.mode == AuthMode.signup;

    return NarooPage(
      child: ListView(
        children: [
          TopBar(onBack: widget.onBack),
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
          NarooTextField(
            controller: _loginIdController,
            label: 'Login ID',
            textInputAction: TextInputAction.next,
          ),
          if (isSignup) ...[
            const SizedBox(height: 12),
            NarooTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
          ],
          const SizedBox(height: 12),
          NarooTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: true,
            textInputAction: isSignup
                ? TextInputAction.next
                : TextInputAction.done,
          ),
          if (isSignup) ...[
            const SizedBox(height: 12),
            NarooTextField(
              controller: _nicknameController,
              label: 'Nickname',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Text('요즘 수학 상태', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final status in widget.mathStatusOptions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ChoiceRow(
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

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.onVerify,
    required this.onLater,
  });

  final String email;
  final VoidCallback onVerify;
  final VoidCallback onLater;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
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

    return NarooPage(
      child: ListView(
        children: [
          const BrandHeader(),
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
          NarooTextField(
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

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.onChanged});

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AuthMode>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: AuthMode.signup, label: Text('Signup')),
        ButtonSegment(value: AuthMode.login, label: Text('Login')),
      ],
      selected: {mode},
      onSelectionChanged: (value) => onChanged(value.first),
    );
  }
}
