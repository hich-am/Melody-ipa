import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:developer';

class JamendoAuthService {
  static const clientId = 'ad40341f';
  static const redirectUri = 'melodyapp://callback';

  Future<String?> login() async {
    try {
      final url = 'https://api.jamendo.com/v3.0/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&response_type=token';
      
      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: 'melodyapp',
      );

      final uri = Uri.parse(result);
      final fragment = uri.fragment; // format: access_token=XXXXX&token_type=bearer
      
      if (fragment.isNotEmpty) {
        final params = Uri.splitQueryString(fragment);
        return params['access_token'];
      }
    } catch (e) {
      log('Auth error: $e');
    }
    return null;
  }
}
