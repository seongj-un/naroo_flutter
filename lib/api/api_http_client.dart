import 'package:http/http.dart' as http;

import 'api_http_client_io.dart'
    if (dart.library.html) 'api_http_client_web.dart';

http.Client createApiHttpClient() => createPlatformHttpClient();
