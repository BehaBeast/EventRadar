import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/backend.dart';
import '../../core/config.dart';
import '../../core/settings.dart';
import '../../l10n/app_localizations.dart';
import '../catalog/repository.dart';

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
        if (user != null) ...[
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: busy ? null : deleteAccount,
            child: Text(l.deleteAccount),
          ),
        ],
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse(AppConfig.privacyPolicyUrl),
            mode: LaunchMode.externalApplication,
          ),
          child: Text(l.privacyPolicy),
        ),
        const SizedBox(height: 24),
        Text(l.foundation, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Future<void> deleteAccount() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteAccountTitle),
        content: Text(l.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.deleteAccount),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => busy = true);
    final client = ref.read(backendProvider)!;
    try {
      await client.rpc('delete_own_account');
      await client.auth.signOut(scope: SignOutScope.local);
      ref.invalidate(favoriteIdsProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.accountDeleted)));
      }
    } catch (e) {
      if (mounted) {
        final message = e is PostgrestException &&
                e.message.contains('ORGANIZER_HAS_EVENTS')
            ? l.organizerHasEvents
            : l.actionError;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
