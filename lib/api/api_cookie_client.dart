import 'package:http/http.dart' as http;

class CookieBackedClient extends http.BaseClient {
  CookieBackedClient(this._inner);

  final http.Client _inner;
  final Map<String, String> _cookies = {};

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_cookies.isNotEmpty) {
      request.headers['Cookie'] = _cookies.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('; ');
    }

    final response = await _inner.send(request);
    _storeCookies(response.headers['set-cookie']);
    return response;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }

  void _storeCookies(String? setCookieHeader) {
    if (setCookieHeader == null || setCookieHeader.isEmpty) {
      return;
    }

    final refreshToken = RegExp(
      r'(?:^|,\s*)refresh_token=([^;,]+)',
    ).firstMatch(setCookieHeader);
    if (refreshToken != null) {
      _cookies['refresh_token'] = refreshToken.group(1)!;
    }
  }
}
