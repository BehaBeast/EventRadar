import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/settings.dart';

enum MapProviderType {
  openStreetMap,
  cartoDb,
  googleMaps,
  yandexMaps,
  mapbox,
}

class MapProviderConfig {
  final MapProviderType provider;
  final String apiKey;
  final String customTileUrl;
  final bool offlineCache;

  const MapProviderConfig({
    this.provider = MapProviderType.openStreetMap,
    this.apiKey = '',
    this.customTileUrl = '',
    this.offlineCache = true,
  });

  bool get isConfigured {
    switch (provider) {
      case MapProviderType.openStreetMap:
      case MapProviderType.cartoDb:
        return true; // Free, open, works out of the box!
      case MapProviderType.googleMaps:
      case MapProviderType.yandexMaps:
      case MapProviderType.mapbox:
        return apiKey.trim().isNotEmpty;
    }
  }

  String get displayName {
    switch (provider) {
      case MapProviderType.openStreetMap:
        return 'OpenStreetMap (OSM)';
      case MapProviderType.cartoDb:
        return 'CartoDB Positron';
      case MapProviderType.googleMaps:
        return 'Google Maps';
      case MapProviderType.yandexMaps:
        return 'Yandex Maps';
      case MapProviderType.mapbox:
        return 'Mapbox';
    }
  }

  String get tileUrl {
    if (customTileUrl.isNotEmpty) return customTileUrl;
    switch (provider) {
      case MapProviderType.openStreetMap:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapProviderType.cartoDb:
        return 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
      case MapProviderType.mapbox:
        return 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$apiKey';
      case MapProviderType.googleMaps:
        return 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&key=$apiKey';
      case MapProviderType.yandexMaps:
        return 'https://core-renderer-tiles.maps.yandex.net/tiles?l=map&x={x}&y={y}&z={z}&apikey=$apiKey';
    }
  }

  MapProviderConfig copyWith({
    MapProviderType? provider,
    String? apiKey,
    String? customTileUrl,
    bool? offlineCache,
  }) {
    return MapProviderConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      customTileUrl: customTileUrl ?? this.customTileUrl,
      offlineCache: offlineCache ?? this.offlineCache,
    );
  }

  Map<String, dynamic> toJson() => {
    'provider': provider.name,
    'apiKey': apiKey,
    'customTileUrl': customTileUrl,
    'offlineCache': offlineCache,
  };

  factory MapProviderConfig.fromJson(Map<String, dynamic> json) =>
      MapProviderConfig(
        provider: MapProviderType.values.firstWhere(
          (p) => p.name == json['provider'],
          orElse: () => MapProviderType.openStreetMap,
        ),
        apiKey: json['apiKey'] as String? ?? '',
        customTileUrl: json['customTileUrl'] as String? ?? '',
        offlineCache: json['offlineCache'] as bool? ?? true,
      );
}

class MapConfigNotifier extends Notifier<MapProviderConfig> {
  static const _storageKey = 'eventradar_map_config';

  @override
  MapProviderConfig build() {
    final prefs = ref.watch(preferencesProvider);
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        return MapProviderConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
    // Default to OpenStreetMap which is 100% active and configured out of the box!
    return const MapProviderConfig();
  }

  Future<void> updateConfig(MapProviderConfig newConfig) async {
    state = newConfig;
    final prefs = ref.read(preferencesProvider);
    await prefs.setString(_storageKey, jsonEncode(newConfig.toJson()));
  }
}

final mapConfigProvider =
    NotifierProvider<MapConfigNotifier, MapProviderConfig>(
      MapConfigNotifier.new,
    );

