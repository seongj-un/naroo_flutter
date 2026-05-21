import 'package:flutter/foundation.dart';

class NarooEnvironment {
  const NarooEnvironment._();

  static const configuredApiBaseUrl = String.fromEnvironment(
    'NAROO_API_BASE_URL',
    defaultValue: '',
  );

  static const buildProfile = String.fromEnvironment(
    'NAROO_BUILD_PROFILE',
    defaultValue: 'local',
  );

  static const allowInsecureApi = bool.fromEnvironment(
    'NAROO_ALLOW_INSECURE_API',
  );

  static bool get isProductionProfile {
    final normalized = buildProfile.toLowerCase();
    return normalized == 'prod' || normalized == 'production';
  }

  static String resolveApiBaseUrl({Uri? baseUri}) {
    if (configuredApiBaseUrl.isNotEmpty) {
      return configuredApiBaseUrl;
    }

    if (kIsWeb) {
      final origin = (baseUri ?? Uri.base).origin;
      if (origin.isNotEmpty && origin != 'null') {
        return origin;
      }
    }

    return 'http://localhost:8080';
  }

  static String? validateApiBaseUrl({
    required bool isReleaseMode,
    Uri? baseUri,
  }) {
    final uri = Uri.tryParse(resolveApiBaseUrl(baseUri: baseUri));
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'API 주소가 올바르지 않아요. NAROO_API_BASE_URL을 https://... 형식으로 설정해 주세요.';
    }

    final requiresSecureApi = isReleaseMode || isProductionProfile;
    if (!requiresSecureApi || allowInsecureApi) {
      return null;
    }

    if (uri.scheme != 'https') {
      return '릴리즈 빌드는 HTTPS API만 사용할 수 있어요. NAROO_API_BASE_URL을 https://... 주소로 설정해 주세요.';
    }

    if (_isLocalHost(uri.host)) {
      return '릴리즈 빌드에는 localhost API를 사용할 수 없어요. 운영 API 도메인을 설정해 주세요.';
    }

    return null;
  }

  static bool _isLocalHost(String host) {
    final normalized = host.toLowerCase();
    return normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '0.0.0.0' ||
        normalized == '::1';
  }
}
