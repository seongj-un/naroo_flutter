import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'config/naroo_environment.dart';
import 'naroo_app.dart';

void main() {
  final startupError = NarooEnvironment.validateApiBaseUrl(
    isReleaseMode: kReleaseMode,
    baseUri: Uri.base,
  );
  runApp(
    NarooApp(
      startupError: startupError,
      initialVerificationToken: initialVerificationTokenFromUri(Uri.base),
      restoreSessionOnStartup: true,
    ),
  );
}

String? initialVerificationTokenFromUri(Uri uri) {
  final token = uri.queryParameters['token']?.trim();
  if (token == null || token.isEmpty) {
    return null;
  }

  final normalizedPath = _normalizeVerificationPath(uri.path);
  if (normalizedPath == '/' || normalizedPath.endsWith('/verify-email')) {
    return token;
  }

  return null;
}

String _normalizeVerificationPath(String path) {
  final normalized = path.trim().toLowerCase();
  if (normalized.isEmpty) {
    return '/';
  }
  if (normalized == '/') {
    return normalized;
  }
  return normalized.endsWith('/')
      ? normalized.substring(0, normalized.length - 1)
      : normalized;
}
