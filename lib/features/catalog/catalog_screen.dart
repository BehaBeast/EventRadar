import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../payments/checkout_sheet.dart';
import 'event.dart';
import 'repository.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});
  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _query = TextEditingController();
  List<RadarEvent> _events = [];
  List<Map<String, dynamic>> _cities = [], _categories = [];
  String? _language, _category;
  int? _city;
  bool _busy = true, _failed = false, _hasMore = false;
  int _request = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    if (_language != code) {
      _language = code;
      _load();
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    final request = ++_request;
    setState(() {
      _busy = true;
      _failed = false;
    });
    final repository = ref.read(catalogRepositoryProvider);
    if (repository == null) {
      setState(() => _busy = false);
      return;
    }
    try {
      final data = await repository.search(
        query: _query.text.trim(),
        city: _city,
        category: _category,
        language: _language!,
        offset: more ? _events.length : 0,
      );
      final cities = _cities.isEmpty
          ? await repository.references('cities')
          : _cities;
      final categories = _categories.isEmpty
          ? await repository.references('categories')
          : _categories;
      categories.sort(
        (a, b) => (a['position'] as int).compareTo(b['position'] as int),
      );
      if (!mounted || request != _request) return;
      setState(() {
        _events = more ? [..._events, ...data] : data;
        _cities = cities;
        _categories = categories;
        _hasMore = data.length == 30;
      });
    } catch (_) {
      if (mounted && request == _request) setState(() => _failed = true);
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  String _name(Map<String, dynamic> row) =>
      (row['names'] as Map)[_language] as String? ??
      (row['names'] as Map)['ru'] as String;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (ref.watch(catalogRepositoryProvider) == null) {
      return StatusPanel(message: l.setupBody);
    }
    return RefreshIndicator(
      onRefresh: () => _load(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l.discover,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(l.foundation, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          TextField(
            controller: _query,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              hintText: l.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: l.search,
                onPressed: _busy ? null : () => _load(),
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _city,
            isExpanded: true,
            decoration: InputDecoration(labelText: l.allCities),
            items: [
              DropdownMenuItem<int>(value: null, child: Text(l.allCities)),
              ..._cities.map(
                (c) => DropdownMenuItem(
                  value: c['id'] as int,
                  child: Text(_name(c)),
                ),
              ),
            ],
            onChanged: _busy
                ? null
                : (v) {
                    setState(() => _city = v);
                    _load();
                  },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            isExpanded: true,
            decoration: InputDecoration(labelText: l.allCategories),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(l.allCategories),
              ),
              ..._categories.map(
                (c) => DropdownMenuItem(
                  value: c['slug'] as String,
                  child: Text(_name(c), overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: _busy
                ? null
                : (v) {
                    setState(() => _category = v);
                    _load();
                  },
          ),
          const SizedBox(height: 24),
          if (_busy) const LinearProgressIndicator(),
          if (_failed)
            StatusPanel(message: l.networkError, retry: () => _load()),
          if (!_busy && !_failed && _events.isEmpty)
            StatusPanel(message: l.empty, icon: Icons.explore_outlined),
          if (!_failed)
            ..._events.map(
              (event) => EventCard(
                event: event,
                onTap: () => context.push('/event', extra: event),
              ),
            ),
          if (_hasMore && !_failed)
            OutlinedButton(
              onPressed: _busy ? null : () => _load(more: true),
              child: Text(l.more),
            ),
        ],
      ),
    );
  }
}

String eventDate(BuildContext context, RadarEvent event) {
  final local = tz.TZDateTime.from(
    event.startsAt,
    tz.getLocation(event.timezone),
  );
  return '${DateFormat.yMMMd(Localizations.localeOf(context).languageCode).add_Hm().format(local)} · ${event.timezone}';
}

class FavoriteButton extends ConsumerStatefulWidget {
  const FavoriteButton({super.key, required this.id});
  final String id;
  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> {
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final favorites = ref.watch(favoriteIdsProvider);
    final saved = favorites.value?.contains(widget.id) ?? false;
    return IconButton(
      tooltip: saved ? l.unsave : l.save,
      icon: Icon(saved ? Icons.favorite : Icons.favorite_border),
      onPressed: busy || favorites.isLoading || favorites.hasError
          ? null
          : () async {
              setState(() => busy = true);
              try {
                await toggleFavorite(ref, widget.id);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.actionError)));
                }
              } finally {
                if (mounted) setState(() => busy = false);
              }
            },
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.onTap});
  final RadarEvent event;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.cityName,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                FavoriteButton(id: event.id),
              ],
            ),
            Text(event.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(eventDate(context, event)),
            const SizedBox(height: 8),
            Text(event.organizerName),
          ],
        ),
      ),
    ),
  );
}

class EventScreen extends StatelessWidget {
  const EventScreen({super.key, required this.event});
  final RadarEvent event;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.details),
        actions: [FavoriteButton(id: event.id)],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: FilledButton.icon(
            icon: const Icon(Icons.confirmation_num),
            label: const Text(
              'Купить билет',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CheckoutSheet(event: event),
              );
            },
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(event.title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 20),
          Text(eventDate(context, event)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.format == 'online'
                      ? l.online
                      : '${event.cityName} · ${event.address}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (event.format != 'online')
                TextButton.icon(
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('На карте'),
                  onPressed: () => context.go('/map'),
                ),
            ],
          ),
          const Divider(height: 40),
          Text('${l.organizer}: ${event.organizerName}'),
          const SizedBox(height: 20),
          Text(
            '${l.originalLanguage}: ${event.contentLanguage.toUpperCase()}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Text(event.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
