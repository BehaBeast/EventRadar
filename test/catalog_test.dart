import 'package:eventradar/app.dart';
import 'package:eventradar/core/settings.dart';
import 'package:eventradar/features/catalog/event.dart';
import 'package:eventradar/features/catalog/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

// Test-only data. No fixtures are referenced by production code or migrations.
class TestCatalog implements EventCatalog {
  String query = '';
  bool fail = false;
  @override
  Future<List<Map<String, dynamic>>> references(String table) async =>
      table == 'cities'
      ? [
          {
            'id': 1,
            'names': {'ru': 'Фергана', 'en': 'Fergana', 'uz': 'Farg‘ona'},
          },
        ]
      : [
          {
            'slug': 'music',
            'position': 1,
            'names': {'ru': 'Музыка', 'en': 'Music', 'uz': 'Musiqa'},
          },
        ];
  @override
  Future<List<RadarEvent>> search({
    String query = '',
    int? city,
    String? category,
    String language = 'ru',
    int offset = 0,
  }) async {
    this.query = query;
    if (fail) throw StateError('Network unavailable');
    if (query == 'none') return [];
    return [
      RadarEvent(
        id: 'event-1',
        title: 'Jazz in Fergana',
        description: 'A live evening of music in the city.',
        contentLanguage: 'en',
        categorySlug: 'music',
        cityId: 1,
        cityName: 'Fergana',
        format: 'offline',
        address: 'City hall',
        startsAt: DateTime.utc(2026, 12, 1, 15),
        endsAt: DateTime.utc(2026, 12, 1, 17),
        timezone: 'Asia/Tashkent',
        organizerName: 'Test organizer',
      ),
    ];
  }
}

void main() {
  testWidgets(
    'catalog loads, opens details, saves guest favorite, searches and retries',
    (tester) async {
      tz.initializeTimeZones();
      SharedPreferences.setMockInitialValues({'language': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final repository = TestCatalog();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefs),
            catalogRepositoryProvider.overrideWithValue(repository),
          ],
          child: const EventRadarApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Jazz in Fergana'), findsOneWidget);
      await tester.tap(find.text('Jazz in Fergana'));
      await tester.pumpAndSettle();
      expect(find.text('A live evening of music in the city.'), findsOneWidget);
      await tester.tap(find.byTooltip('Save event').last);
      await tester.pumpAndSettle();
      expect(prefs.getStringList('guestFavorites'), ['event-1']);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'none');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(repository.query, 'none');
      expect(
        find.text('No events yet. Try changing your search.'),
        findsOneWidget,
      );
      repository.fail = true;
      await tester.enterText(find.byType(TextField), 'jazz');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(
        find.text('Could not load data. Check your connection and retry.'),
        findsOneWidget,
      );
      repository.fail = false;
      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Jazz in Fergana'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
