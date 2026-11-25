import 'dart:convert';
import 'package:eventradar/core/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('client configuration rejects server credentials and templates', () {
    const url = 'https://project.supabase.co';
    expect(AppConfig.valid(url, 'sb_publishable_test'), isTrue);
    expect(AppConfig.valid(url, 'sb_secret_test'), isFalse);
    expect(
      AppConfig.valid('http://project.supabase.co', 'sb_publishable_test'),
      isFalse,
    );
    expect(
      AppConfig.valid(
        'https://YOUR_PROJECT.supabase.co',
        'sb_publishable_REPLACE_ME',
      ),
      isFalse,
    );
    String jwt(String role) =>
        'header.${base64Url.encode(utf8.encode(jsonEncode({'role': role})))}.signature';
    expect(AppConfig.valid(url, jwt('anon')), isTrue);
    expect(AppConfig.valid(url, jwt('service_role')), isFalse);
    expect(AppConfig.valid(url, 'invalid'), isFalse);
  });
}
