import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'config/naroo_environment.dart';
import 'naroo_app.dart';

void main() {
  final startupError = NarooEnvironment.validateApiBaseUrl(
    isReleaseMode: kReleaseMode,
  );
  runApp(
    NarooApp(
      startupError: startupError,
      initialVerificationToken: _initialVerificationToken(),
    ),
  );
}

String? _initialVerificationToken() {
  final token = Uri.base.queryParameters['token']?.trim();
  if (token == null || token.isEmpty) {
    return null;
  }

  final path = Uri.base.path.toLowerCase();
  if (path.isEmpty || path == '/' || path == '/verify-email') {
    return token;
  }

  return null;
}
