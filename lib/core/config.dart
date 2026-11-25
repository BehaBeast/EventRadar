import 'dart:convert';

class AppConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const privacyPolicyUrl =
      'https://behabeast.github.io/EventRadar/privacy.html';
  static bool get configured => valid(url, key);
  static bool valid(String url, String key) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.host.toLowerCase().contains('your_project') ||
        uri.userInfo.isNotEmpty ||
        key.isEmpty ||
        key.contains('REPLACE_ME')) {
      return false;
    }
    if (key.startsWith('sb_publishable_')) return true;
    // Only legacy anon JWTs are permitted; reject service_role/secret keys.
    try {
      final parts = key.split('.');
      if (parts.length != 3) return false;
      final claims = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return claims is Map && claims['role'] == 'anon';
    } catch (_) {
      return false;
    }
  }
}
