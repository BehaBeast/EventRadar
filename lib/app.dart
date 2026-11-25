import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/settings.dart';
import 'core/theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/catalog/catalog_screen.dart';
import 'features/catalog/event.dart';
import 'features/map/map_screen.dart';
import 'features/notifications/in_app_banner.dart';
import 'features/notifications/notification_service.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/payments/my_tickets_screen.dart';
import 'features/profile/profile_screen.dart';
import 'l10n/app_localizations.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/', builder: (_, _) => const CatalogScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/map', builder: (_, _) => const MapScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/auth', builder: (_, _) => const AuthScreen()),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/tickets',
        builder: (_, _) => const MyTicketsScreen(),
      ),
      GoRoute(
        path: '/event',
        redirect: (_, state) => state.extra is RadarEvent ? null : '/',
        builder: (_, state) => EventScreen(event: state.extra! as RadarEvent),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class EventRadarApp extends ConsumerWidget {
  const EventRadarApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'EventRadar',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      theme: eventRadarTheme(Brightness.light),
      darkTheme: eventRadarTheme(Brightness.dark),
      themeMode: settings.theme,
      locale: settings.language == null ? null : Locale(settings.language!),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (locale, supported) => supported.firstWhere(
        (l) => l.languageCode == locale?.languageCode,
        orElse: () => const Locale('ru'),
      ),
    );
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final unreadNotifs = ref.watch(
      notificationProvider.select((s) => s.unreadCount),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          IconButton(
            tooltip: 'Push-уведомления',
            icon: Badge(
              isLabelVisible: unreadNotifs > 0,
              label: Text('$unreadNotifs'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: InAppNotificationBanner(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: shell,
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.radar),
            label: l.catalog,
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Карта',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l.profile,
          ),
        ],
      ),
    );
  }
}
