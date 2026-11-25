import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

final backendProvider = Provider<SupabaseClient?>(
  (ref) => AppConfig.configured ? Supabase.instance.client : null,
);
final authProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(backendProvider);
  return client?.auth.onAuthStateChange ?? const Stream.empty();
});
final userIdProvider = Provider<String?>((ref) {
  ref.watch(authProvider);
  return ref.watch(backendProvider)?.auth.currentUser?.id;
});
