import 'package:flutter/material.dart';

import 'naroo_dependencies.dart';
import 'naroo_shell.dart';
import 'naroo_theme.dart';

class NarooApp extends StatelessWidget {
  const NarooApp({
    super.key,
    this.dependencies,
    this.startupError,
    this.initialVerificationToken,
    this.restoreSessionOnStartup = false,
  });

  final NarooDependencies? dependencies;
  final String? startupError;
  final String? initialVerificationToken;
  final bool restoreSessionOnStartup;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naroo',
      debugShowCheckedModeBanner: false,
      theme: buildNarooTheme(),
      home: startupError == null
          ? NarooShell(
              dependencies: dependencies ?? NarooDependencies.real(),
              initialVerificationToken: initialVerificationToken,
              restoreSessionOnStartup: restoreSessionOnStartup,
            )
          : _StartupErrorScreen(message: startupError!),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '앱 설정을 확인해 주세요',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(message, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
