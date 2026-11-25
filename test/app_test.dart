import 'package:eventradar/app.dart';
import 'package:eventradar/core/settings.dart';
import 'package:eventradar/features/catalog/event.dart';
import 'package:eventradar/features/catalog/catalog_screen.dart';
import 'package:eventradar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final code in ['ru', 'uz', 'en']) {
    testWidgets('unconfigured app works in $code on narrow screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', code);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [preferencesProvider.overrideWithValue(prefs)],
          child: const EventRadarApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('EventRadar'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButtonFormField<ThemeMode>), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  test('theme and language persist between controllers', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(prefs)],
    );
    await container.read(settingsProvider.notifier).setTheme(ThemeMode.dark);
    await container.read(settingsProvider.notifier).setLanguage('uz');
    container.dispose();
    final next = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(prefs)],
    );
    expect(next.read(settingsProvider).theme, ThemeMode.dark);
    expect(next.read(settingsProvider).language, 'uz');
    next.dispose();
  });
  testWidgets('event date uses event zone instead of device zone', (
    tester,
  ) async {
    tz.initializeTimeZones();
    final event = RadarEvent.fromJson({
      'id': 'one',
      'title': 'Title',
      'description': 'Description',
      'content_language': 'en',
      'category_slug': 'music',
      'city_id': 1,
      'city_name': 'Fergana',
      'format': 'offline',
      'address': 'Hall',
      'starts_at': '2026-12-01T20:30:00Z',
      'ends_at': '2026-12-01T21:30:00Z',
      'timezone': 'Asia/Tashkent',
      'organizer_name': 'Org',
    });
    String? formatted;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            formatted = eventDate(context, event);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(formatted, contains('Dec 2, 2026'));
    expect(formatted, contains('01:30'));
    expect(formatted, contains('Asia/Tashkent'));
    expect(RadarEvent.fromJson(event.toJson()), event);
  });
}
