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
    required this.isLoading,
    required this.errorMessage,
    required this.statusMessage,
    required this.onModeChanged,
    required this.onBack,
    required this.onSignup,
    required this.onLogin,
  });

  final AuthMode mode;
  final List<String> mathStatusOptions;
  final bool isLoading;
  final String? errorMessage;
  final String? statusMessage;
  final ValueChanged<AuthMode> onModeChanged;
  final VoidCallback onBack;
  final Future<void> Function({
    required String loginId,
    required String email,
    required String password,
    required String nickname,
    required String mathStatus,
  })
  onSignup;
  final Future<void> Function({
    required String loginId,
    required String password,
  })
  onLogin;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  late String _mathStatus = widget.mathStatusOptions.last;
  String? _inlineMessage;

  @override
  void initState() {
    super.initState();
    _loginIdController.addListener(_clearInlineMessage);
    _emailController.addListener(_clearInlineMessage);
    _passwordController.addListener(_clearInlineMessage);
    _nicknameController.addListener(_clearInlineMessage);
  }

  @override
  void didUpdateWidget(covariant AuthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _inlineMessage = null;
    }
  }

  @override
  void dispose() {
    _loginIdController.removeListener(_clearInlineMessage);
    _emailController.removeListener(_clearInlineMessage);
    _passwordController.removeListener(_clearInlineMessage);
    _nicknameController.removeListener(_clearInlineMessage);
    _loginIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSignup = widget.mode == AuthMode.signup;
    final statusText = widget.isLoading
        ? '기록을 확인하는 중...'
        : widget.errorMessage ?? widget.statusMessage ?? _inlineMessage;

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
          if (statusText != null) ...[
            const SizedBox(height: 12),
            Text(statusText, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 24),
          NarooTextField(
            controller: _loginIdController,
            label: 'Login ID',
            textInputAction: TextInputAction.next,
            onChanged: (_) => _clearInlineMessage(),
          ),
          if (isSignup) ...[
            const SizedBox(height: 12),
            NarooTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _clearInlineMessage(),
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
            onChanged: (_) => _clearInlineMessage(),
          ),
          if (isSignup) ...[
            const SizedBox(height: 12),
            NarooTextField(
              controller: _nicknameController,
              label: 'Nickname',
              textInputAction: TextInputAction.next,
              onChanged: (_) => _clearInlineMessage(),
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
            onPressed: widget.isLoading
                ? null
                : () async {
                    final loginId = _loginIdController.text.trim();
                    final password = _passwordController.text;

                    if (isSignup) {
                      final email = _emailController.text.trim();
                      final nickname = _nicknameController.text.trim();
                      if (loginId.isEmpty ||
                          email.isEmpty ||
                          password.isEmpty ||
                          nickname.isEmpty) {
                        setState(() {
                          _inlineMessage =
                              '아이디, 이메일, 비밀번호, 닉네임을 모두 입력해 주세요.';
                        });
                        return;
                      }
                      _clearInlineMessage();
                      await widget.onSignup(
                        loginId: loginId,
                        nickname: nickname,
                        email: email,
                        password: password,
                        mathStatus: _mathStatus,
                      );
                      return;
                    }
                    if (loginId.isEmpty || password.isEmpty) {
                      setState(() {
                        _inlineMessage = '아이디와 비밀번호를 입력해 주세요.';
                      });
                      return;
                    }
                    _clearInlineMessage();
                    await widget.onLogin(
                      loginId: loginId,
                      password: password,
                    );
                  },
            child: Text(isSignup ? '내 기록 만들기' : '기록 불러오기'),
          ),
        ],
      ),
    );
  }

  void _clearInlineMessage() {
    if (_inlineMessage == null) {
      return;
    }
    setState(() {
      _inlineMessage = null;
    });
  }
}

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.isLoading,
    required this.isLinkFlow,
    required this.showLinkFailureState,
    required this.showResendAction,
    required this.isResendCoolingDown,
    required this.resendCooldownMessage,
    required this.errorMessage,
    required this.statusMessage,
    required this.onVerify,
    required this.onResend,
    required this.onUseCodeInstead,
    required this.onBackToLogin,
    required this.onLater,
  });

  final String email;
  final bool isLoading;
  final bool isLinkFlow;
  final bool showLinkFailureState;
  final bool showResendAction;
  final bool isResendCoolingDown;
  final String? resendCooldownMessage;
  final String? errorMessage;
  final String? statusMessage;
  final Future<void> Function(String token) onVerify;
  final Future<void> Function() onResend;
  final VoidCallback onUseCodeInstead;
  final VoidCallback onBackToLogin;
  final VoidCallback onLater;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _tokenController = TextEditingController();
  String? _message;

  @override
  void initState() {
    super.initState();
    _tokenController.addListener(_clearMessage);
  }

  @override
  void dispose() {
    _tokenController.removeListener(_clearMessage);
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email.isEmpty ? '가입한 이메일' : widget.email;
    final showLinkFailureState =
        widget.showLinkFailureState ||
        (widget.isLinkFlow && widget.errorMessage != null && !widget.isLoading);
    final showStatusText =
        !showLinkFailureState &&
        (widget.isLoading ||
            widget.errorMessage != null ||
            widget.statusMessage != null ||
            _message != null);
    final resendButtonLabel = widget.isResendCoolingDown
        ? '인증 메일 다시 보내기'
        : '인증 메일 다시 보내기';
    final resendHelpText = widget.resendCooldownMessage;

    return NarooPage(
      child: ListView(
        children: [
          const BrandHeader(),
          const SizedBox(height: 48),
          Text(
            showLinkFailureState ? '인증 링크를 다시 확인해 주세요' : '이메일 확인이 필요해요',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            showLinkFailureState
                ? '링크가 만료됐거나 이미 사용됐을 수 있어요. 메일함에서 가장 최근에 받은 링크를 다시 열거나, 인증 코드를 직접 입력해 주세요.'
                : '$email 기록을 안전하게 저장하려면 이메일 인증을 먼저 완료해야 해요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (!showLinkFailureState) ...[
            const SizedBox(height: 24),
            NarooTextField(
              controller: _tokenController,
              label: '인증 코드',
              textInputAction: TextInputAction.done,
              onChanged: (_) => _clearMessage(),
            ),
          ],
          if (showStatusText) ...[
            const SizedBox(height: 8),
            Text(
              widget.isLoading
                  ? '기록을 확인하는 중...'
                  : widget.errorMessage ?? widget.statusMessage ?? _message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (showLinkFailureState && widget.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.isLoading
                ? null
                : showLinkFailureState && !widget.showResendAction
                ? widget.onBackToLogin
                : showLinkFailureState && widget.showResendAction
                ? (widget.isResendCoolingDown ? null : widget.onResend)
                : () async {
                    final token = _tokenController.text.trim();
                    if (token.isEmpty) {
                      setState(() => _message = '인증 코드를 입력해 주세요.');
                      return;
                    }
                    setState(() => _message = '인증을 확인하는 중...');
                    await widget.onVerify(token);
                  },
            child: Text(
              showLinkFailureState
                  ? widget.showResendAction
                        ? resendButtonLabel
                        : '로그인으로 돌아가기'
                  : '인증 완료하기',
            ),
          ),
          if (widget.showResendAction && !showLinkFailureState) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.isLoading || widget.isResendCoolingDown
                  ? null
                  : widget.onResend,
              child: const Text('인증 메일 다시 보내기'),
            ),
          ],
          if (widget.showResendAction &&
              resendHelpText != null &&
              resendHelpText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              resendHelpText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: showLinkFailureState ? widget.onUseCodeInstead : widget.onLater,
            child: Text(showLinkFailureState ? '인증 코드 직접 입력' : '나중에 다시 시도'),
          ),
        ],
      ),
    );
  }

  void _clearMessage() {
    if (_message == null) {
      return;
    }
    setState(() {
      _message = null;
    });
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
