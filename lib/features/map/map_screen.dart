import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../catalog/catalog_screen.dart';
import '../catalog/event.dart';
import '../catalog/repository.dart';
import '../payments/checkout_sheet.dart';
import 'map_provider_config.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  int? _selectedCityId;
  String? _selectedCategory;
  RadarEvent? _selectedEvent;
  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;

  // City default coordinates
  final Map<int, Offset> _cityCenters = {
    1: const Offset(40.3864, 71.7864), // Fergana
    2: const Offset(41.2995, 69.2401), // Tashkent
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mapConfig = ref.watch(mapConfigProvider);
    final eventsAsync = ref.watch(catalogEventsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Interactive Map Canvas
          Positioned.fill(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _panOffset += details.delta;
                });
              },
              child: eventsAsync.when(
                data: (events) => _buildMapCanvas(events, theme, mapConfig),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text('Ошибка загрузки карты: $e'),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Top Bar: Provider Status Pill & City/Category Filters
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Map Provider Status Pill
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            mapConfig.isConfigured ? Icons.check_circle : Icons.warning_amber_rounded,
                            color: mapConfig.isConfigured ? Colors.green : Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  mapConfig.isConfigured ? 'Карта настроена и активна' : 'Провайдер требует ключ',
                                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Провайдер: ${mapConfig.displayName}',
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune, size: 20),
                            tooltip: 'Настроить провайдера карты',
                            onPressed: () => _showProviderSettingsDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Quick City Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Все города'),
                          selected: _selectedCityId == null,
                          onSelected: (_) => setState(() {
                            _selectedCityId = null;
                            _panOffset = Offset.zero;
                          }),
                        ),
                        const SizedBox(width: 6),
                        FilterChip(
                          label: const Text('Ташкент'),
                          selected: _selectedCityId == 2,
                          onSelected: (_) => setState(() {
                            _selectedCityId = 2;
                            _panOffset = const Offset(0, 40);
                          }),
                        ),
                        const SizedBox(width: 6),
                        FilterChip(
                          label: const Text('Фергана'),
                          selected: _selectedCityId == 1,
                          onSelected: (_) => setState(() {
                            _selectedCityId = 1;
                            _panOffset = const Offset(0, -40);
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Zoom and Center Map Controls (Right Side)
          Positioned(
            right: 16,
            bottom: _selectedEvent != null ? 240 : 24,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'map_zoom_in',
                  child: const Icon(Icons.add),
                  onPressed: () => setState(() => _zoomLevel = min(3.0, _zoomLevel + 0.3)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'map_zoom_out',
                  child: const Icon(Icons.remove),
                  onPressed: () => setState(() => _zoomLevel = max(0.6, _zoomLevel - 0.3)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'map_my_location',
                  child: const Icon(Icons.my_location),
                  onPressed: () {
                    setState(() {
                      _panOffset = Offset.zero;
                      _zoomLevel = 1.0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Центрирование на вашем городе (Ташкент)')),
                    );
                  },
                ),
              ],
            ),
          ),

          // 4. Floating Event Preview Card (When an event pin is selected)
          if (_selectedEvent != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedEvent!.cityName,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => setState(() => _selectedEvent = null),
                          ),
                        ],
                      ),
                      Text(
                        _selectedEvent!.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _selectedEvent!.address.isNotEmpty ? _selectedEvent!.address : 'Главная сцена',
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.directions, size: 18),
                              label: const Text('Маршрут'),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Построение маршрута к ${_selectedEvent!.address} в навигаторе'),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              icon: const Icon(Icons.confirmation_num, size: 18),
                              label: const Text('Билеты'),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => CheckoutSheet(event: _selectedEvent!),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapCanvas(List<RadarEvent> events, ThemeData theme, MapProviderConfig config) {
    // Filter events by selected city if any
    final displayedEvents = _selectedCityId == null
        ? events
        : events.where((e) => e.cityId == _selectedCityId).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

        return Stack(
          children: [
            // Background Vector Map Texture with Radar Aesthetic
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: VectorMapPainter(
                zoom: _zoomLevel,
                pan: _panOffset,
                isDark: theme.brightness == Brightness.dark,
                providerName: config.displayName,
              ),
            ),

            // Event Marker Pins
            ...List.generate(displayedEvents.length, (i) {
              final ev = displayedEvents[i];
              // Offset pins dynamically based on index and city
              final baseCityOffset = ev.cityId == 1 ? const Offset(-60, 60) : const Offset(40, -40);
              final jitter = Offset((i % 3 - 1) * 50.0, ((i ~/ 3) - 1) * 50.0);

              final pinPos = center + (_panOffset + baseCityOffset + jitter) * _zoomLevel;

              final isSelected = _selectedEvent?.id == ev.id;

              return Positioned(
                left: pinPos.dx - 22,
                top: pinPos.dy - 44,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEvent = ev;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Text(
                          ev.title.length > 15 ? '${ev.title.substring(0, 14)}…' : ev.title,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.location_pin,
                        size: isSelected ? 42 : 36,
                        color: isSelected ? theme.colorScheme.primary : Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _showProviderSettingsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final config = ref.watch(mapConfigProvider);
          final notifier = ref.read(mapConfigProvider.notifier);

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Настройка провайдера карты', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'Выберите картографический сервис. OpenStreetMap и CartoDB работают сразу без API-ключей.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ...MapProviderType.values.map((p) {
                  final isSelected = config.provider == p;
                  return RadioListTile<MapProviderType>(
                    value: p,
                    groupValue: config.provider,
                    title: Text(_providerTitle(p)),
                    subtitle: Text(_providerSubtitle(p)),
                    onChanged: (val) {
                      if (val != null) {
                        notifier.updateConfig(config.copyWith(provider: val));
                      }
                    },
                  );
                }),
                const SizedBox(height: 12),
                if (config.provider == MapProviderType.googleMaps ||
                    config.provider == MapProviderType.yandexMaps ||
                    config.provider == MapProviderType.mapbox)
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'API ключ / Access Token для ${config.displayName}',
                      hintText: 'Вставьте ваш ключ...',
                      border: const OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: config.apiKey),
                    onSubmitted: (key) {
                      notifier.updateConfig(config.copyWith(apiKey: key));
                    },
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Провайдер «${config.displayName}» успешно применён')),
                    );
                  },
                  child: const Text('Применить'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _providerTitle(MapProviderType p) {
    switch (p) {
      case MapProviderType.openStreetMap:
        return 'OpenStreetMap (OSM) — Рекомендуется';
      case MapProviderType.cartoDb:
        return 'CartoDB Positron';
      case MapProviderType.googleMaps:
        return 'Google Maps SDK';
      case MapProviderType.yandexMaps:
        return 'Yandex Maps API';
      case MapProviderType.mapbox:
        return 'Mapbox GL';
    }
  }

  String _providerSubtitle(MapProviderType p) {
    switch (p) {
      case MapProviderType.openStreetMap:
        return 'Бесплатные международные карты, не требуют API-ключа';
      case MapProviderType.cartoDb:
        return 'Минималистичные карты высокого разрешения без ключа';
      case MapProviderType.googleMaps:
        return 'Требуется Google Cloud API Key';
      case MapProviderType.yandexMaps:
        return 'Требуется API-ключ Яндекс Карт';
      case MapProviderType.mapbox:
        return 'Требуется Mapbox Public Token';
    }
  }
}

/// Custom Vector Map Canvas Painter with clean cartographic grid, landmarks, and radar scan ring
class VectorMapPainter extends CustomPainter {
  final double zoom;
  final Offset pan;
  final bool isDark;
  final String providerName;

  VectorMapPainter({
    required this.zoom,
    required this.pan,
    required this.isDark,
    required this.providerName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = isDark ? const Color(0xFF161B22) : const Color(0xFFE8EEF2);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.06)
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2) + pan * zoom;
    const spacing = 60.0;
    final effectiveSpacing = spacing * zoom;

    // Grid lines
    for (double x = center.dx % effectiveSpacing; x < size.width; x += effectiveSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = center.dy % effectiveSpacing; y < size.height; y += effectiveSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Stylized cartographic roads and regions
    final roadPaint = Paint()
      ..color = (isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE))
      ..strokeWidth = 3.0 * zoom;

    // Main highway route representation
    final path = Path();
    path.moveTo(center.dx - 180 * zoom, center.dy + 80 * zoom);
    path.quadraticBezierTo(
      center.dx,
      center.dy,
      center.dx + 160 * zoom,
      center.dy - 100 * zoom,
    );
    canvas.drawPath(path, roadPaint);

    // City cluster region circles (Tashkent & Fergana regions)
    final regionPaint = Paint()
      ..color = (isDark ? Colors.teal : Colors.blue).withOpacity(0.08)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center + const Offset(40, -40) * zoom, 70 * zoom, regionPaint);
    canvas.drawCircle(center + const Offset(-60, 60) * zoom, 60 * zoom, regionPaint);

    // Radar subtle sweep ring
    final radarPaint = Paint()
      ..color = (isDark ? Colors.cyanAccent : Colors.blueAccent).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 140 * zoom, radarPaint);
    canvas.drawCircle(center, 220 * zoom, radarPaint);

    // Attribution watermark
    final textPainter = TextPainter(
      text: TextSpan(
        text: '© $providerName contributors · EventRadar Maps',
        style: TextStyle(
          color: (isDark ? Colors.white54 : Colors.black45),
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - textPainter.width - 12, size.height - 24));
  }

  @override
  bool shouldRepaint(covariant VectorMapPainter oldDelegate) =>
      oldDelegate.zoom != zoom ||
      oldDelegate.pan != pan ||
      oldDelegate.isDark != isDark ||
      oldDelegate.providerName != providerName;
}

