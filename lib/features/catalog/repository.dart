import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/backend.dart';
import '../../core/settings.dart';
import 'event.dart';

abstract interface class EventCatalog {
  Future<List<RadarEvent>> search({
    String query = '',
    int? city,
    String? category,
    String language = 'ru',
    int offset = 0,
  });
  Future<List<Map<String, dynamic>>> references(String table);
}

class CatalogRepository implements EventCatalog {
  CatalogRepository(this.client);
  final SupabaseClient client;
  @override
  Future<List<RadarEvent>> search({
    String query = '',
    int? city,
    String? category,
    String language = 'ru',
    int offset = 0,
  }) async {
    final data = await client.rpc(
      'search_events',
      params: {
        'p_query': query,
        'p_city': city,
        'p_category': category,
        'p_language': language,
        'p_offset': offset,
      },
    );
    return (data as List)
        .map((e) => RadarEvent.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> references(String table) async =>
      client.from(table).select();
}

final catalogRepositoryProvider = Provider<EventCatalog?>((ref) {
  final client = ref.watch(backendProvider);
  return client == null ? null : CatalogRepository(client);
});
final favoriteIdsProvider = FutureProvider<Set<String>>((ref) async {
  final user = ref.watch(userIdProvider);
  if (user == null) {
    return ref
            .watch(preferencesProvider)
            .getStringList('guestFavorites')
            ?.toSet() ??
        {};
  }
  final rows = await ref
      .watch(backendProvider)!
      .from('favorites')
      .select('event_id')
      .eq('user_id', user);
  return rows.map((e) => e['event_id'] as String).toSet();
});
Future<void> toggleFavorite(WidgetRef ref, String id) async {
  final ids = await ref.read(favoriteIdsProvider.future);
  final user = ref.read(userIdProvider);
  final remove = ids.contains(id);
  if (user == null) {
    final next = {...ids};
    remove ? next.remove(id) : next.add(id);
    await ref
        .read(preferencesProvider)
        .setStringList('guestFavorites', next.toList());
  } else {
    final table = ref.read(backendProvider)!.from('favorites');
    if (remove) {
      await table.delete().eq('user_id', user).eq('event_id', id);
    } else {
      await table.upsert(
        {'user_id': user, 'event_id': id},
        onConflict: 'user_id,event_id',
        ignoreDuplicates: true,
      );
    }
  }
  ref.invalidate(favoriteIdsProvider);
}
