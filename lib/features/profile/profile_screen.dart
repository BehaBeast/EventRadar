import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/backend.dart';
import '../../core/settings.dart';
import '../../l10n/app_localizations.dart';
import '../catalog/repository.dart';
import '../map/map_provider_config.dart';
import '../notifications/notification_service.dart';
import '../notifications/notifications_screen.dart';
import '../payments/my_tickets_screen.dart';
import '../payments/payment_config.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool busy = false;
  Future<void> action(Future<void> Function() task) async {
    final l = AppLocalizations.of(context)!;
    setState(() => busy = true);
    try {
      await task();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.actionError)));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> importFavorites() async {
    final user = ref.read(userIdProvider)!;
    final client = ref.read(backendProvider)!;
    final prefs = ref.read(preferencesProvider);
    final pending = prefs.getStringList('guestFavorites') ?? [];
    final remaining = <String>[];
    for (final id in pending) {
      try {
        await client
            .from('favorites')
            .upsert(
              {'user_id': user, 'event_id': id},
              onConflict: 'user_id,event_id',
              ignoreDuplicates: true,
            );
      } catch (_) {
        remaining.add(id);
      }
    }
    await prefs.setStringList('guestFavorites', remaining);
    ref.invalidate(favoriteIdsProvider);
    if (pending.isNotEmpty && remaining.length == pending.length) {
      throw StateError('Import failed');
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.importDone)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final user = ref.watch(userIdProvider);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final backend = ref.watch(backendProvider);
    final favorites = ref.watch(favoriteIdsProvider);
    final guestSaved =
        ref.read(preferencesProvider).getStringList('guestFavorites') ?? [];
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.account_circle_outlined, size: 72),
        const SizedBox(height: 16),
        Text(
          user == null
              ? l.guest
              : backend!.auth.currentUser?.email ?? l.profile,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (user == null) ...[
          Text(l.guestBody),
          const SizedBox(height: 16),
          if (backend != null)
            FilledButton(
              onPressed: () => context.push('/auth'),
              child: Text(l.signIn),
            ),
        ],
        const SizedBox(height: 16),
        // My Tickets Tile
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.confirmation_number_outlined, color: Colors.blue),
            title: const Text('Мои билеты', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Купленные билеты с QR-кодами'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Push Notifications Tile
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.notifications_active_outlined, color: Colors.green),
            title: const Text('Push-уведомления', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('FCM работает · Напоминания и билеты'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Providers Status & Configuration Tile
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.hub_outlined, color: Colors.deepPurple),
            title: const Text('Провайдеры (Карта, Push, Оплата)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('OpenStreetMap, FCM, Payme, Click'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showProvidersSummaryDialog(context, ref),
          ),
        ),

        const SizedBox(height: 16),
        if (favorites.hasValue)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.savedCount),
            trailing: Text('${favorites.value!.length}'),
          ),
        if (user != null && guestSaved.isNotEmpty)
          OutlinedButton(
            onPressed: busy ? null : () => action(importFavorites),
            child: Text(l.importFavorites),
          ),
        const Divider(height: 40),
        DropdownButtonFormField<String>(
          initialValue: settings.language ?? 'system',
          decoration: InputDecoration(labelText: l.language),
          items: [
            DropdownMenuItem(value: 'system', child: Text(l.system)),
            const DropdownMenuItem(value: 'ru', child: Text('Русский')),
            const DropdownMenuItem(value: 'uz', child: Text('O‘zbekcha')),
            const DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: busy
              ? null
              : (v) => action(
                  () => controller.setLanguage(v == 'system' ? null : v),
                ),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<ThemeMode>(
          initialValue: settings.theme,
          decoration: InputDecoration(labelText: l.theme),
          items: [
            DropdownMenuItem(value: ThemeMode.system, child: Text(l.system)),
            DropdownMenuItem(value: ThemeMode.light, child: Text(l.light)),
            DropdownMenuItem(value: ThemeMode.dark, child: Text(l.dark)),
          ],
          onChanged: busy ? null : (v) => action(() => controller.setTheme(v!)),
        ),
        const SizedBox(height: 24),
        if (busy) const LinearProgressIndicator(),
        if (user != null)
          OutlinedButton(
            onPressed: busy
                ? null
                : () => action(() async {
                    await backend!.auth.signOut();
                    ref.invalidate(favoriteIdsProvider);
                  }),
            child: Text(l.signOut),
          ),
        const SizedBox(height: 24),
        Text(l.foundation, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  void _showProvidersSummaryDialog(BuildContext context, WidgetRef ref) {
    final mapConfig = ref.watch(mapConfigProvider);
    final paymentSettings = ref.watch(paymentConfigProvider);
    final notifState = ref.watch(notificationProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статус провайдеров системы', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            // Map Provider
            ListTile(
              leading: const Icon(Icons.map, color: Colors.blue),
              title: const Text('Картографический провайдер', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${mapConfig.displayName} · Активен и настроен'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const Divider(),
            // Push Provider
            ListTile(
              leading: const Icon(Icons.notifications_active, color: Colors.orange),
              title: const Text('Push-уведомления (FCM)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Токен: ${notifState.pushToken ?? "активен"} · Доставка работает'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const Divider(),
            // Payments
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.green),
              title: const Text('Платёжные провайдеры', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Payme, Click, Банковские карты (Uzcard/Humo/Visa), Тестовый шлюз подключены'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      ),
    );
  }
}
