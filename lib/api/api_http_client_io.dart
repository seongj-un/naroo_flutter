import 'package:http/http.dart' as http;

import 'api_cookie_client.dart';

http.Client createPlatformHttpClient() => CookieBackedClient(http.Client());
