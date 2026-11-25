import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/backend.dart';
import '../../core/settings.dart';
import 'notification_model.dart';

class NotificationSettings {
  final bool ticketAlerts;
  final bool reminder24h;
  final bool reminder1h;
  final bool eventUpdates;
  final bool marketing;

  const NotificationSettings({
    this.ticketAlerts = true,
    this.reminder24h = true,
    this.reminder1h = true,
    this.eventUpdates = true,
    this.marketing = false,
  });

  NotificationSettings copyWith({
    bool? ticketAlerts,
    bool? reminder24h,
    bool? reminder1h,
    bool? eventUpdates,
    bool? marketing,
  }) {
    return NotificationSettings(
      ticketAlerts: ticketAlerts ?? this.ticketAlerts,
      reminder24h: reminder24h ?? this.reminder24h,
      reminder1h: reminder1h ?? this.reminder1h,
      eventUpdates: eventUpdates ?? this.eventUpdates,
      marketing: marketing ?? this.marketing,
    );
  }

  Map<String, dynamic> toJson() => {
    'ticketAlerts': ticketAlerts,
    'reminder24h': reminder24h,
    'reminder1h': reminder1h,
    'eventUpdates': eventUpdates,
    'marketing': marketing,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        ticketAlerts: json['ticketAlerts'] as bool? ?? true,
        reminder24h: json['reminder24h'] as bool? ?? true,
        reminder1h: json['reminder1h'] as bool? ?? true,
        eventUpdates: json['eventUpdates'] as bool? ?? true,
        marketing: json['marketing'] as bool? ?? false,
      );
}

class NotificationState {
  final List<NotificationItem> items;
  final String? pushToken;
  final bool permissionGranted;
  final NotificationSettings settings;
  final NotificationItem? latestBanner;

  const NotificationState({
    this.items = const [],
    this.pushToken,
    this.permissionGranted = true,
    this.settings = const NotificationSettings(),
    this.latestBanner,
  });

  int get unreadCount => items.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationItem>? items,
    String? pushToken,
    bool? permissionGranted,
    NotificationSettings? settings,
    NotificationItem? latestBanner,
    bool clearBanner = false,
  }) {
    return NotificationState(
      items: items ?? this.items,
      pushToken: pushToken ?? this.pushToken,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      settings: settings ?? this.settings,
      latestBanner: clearBanner ? null : (latestBanner ?? this.latestBanner),
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  static const _storageKey = 'eventradar_notifications';
  static const _settingsKey = 'eventradar_notification_settings';
  static const _tokenKey = 'eventradar_fcm_token';

  @override
  NotificationState build() {
    final prefs = ref.watch(preferencesProvider);
    _loadFromStorage(prefs);
    return const NotificationState(
      pushToken: 'fcm_er_dev_${100000 + 42}',
      permissionGranted: true,
    );
  }

  void _loadFromStorage(SharedPreferences prefs) {
    try {
      final savedSettingsJson = prefs.getString(_settingsKey);
      final settings = savedSettingsJson != null
          ? NotificationSettings.fromJson(jsonDecode(savedSettingsJson) as Map<String, dynamic>)
          : const NotificationSettings();

      final savedToken = prefs.getString(_tokenKey) ?? 'fcm_er_dev_live_token';
      final savedNotifsJson = prefs.getStringList(_storageKey);
      List<NotificationItem> list = [];
      if (savedNotifsJson != null) {
        list = savedNotifsJson
            .map((s) => NotificationItem.fromJson(jsonDecode(s) as Map<String, dynamic>))
            .toList();
      }

      state = state.copyWith(
        items: list,
        pushToken: savedToken,
        settings: settings,
      );
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    final prefs = ref.read(preferencesProvider);
    final itemsJson = state.items.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_storageKey, itemsJson);
    await prefs.setString(_settingsKey, jsonEncode(state.settings.toJson()));
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    state = state.copyWith(settings: newSettings);
    await _saveToStorage();
  }

  void clearBanner() {
    state = state.copyWith(clearBanner: true);
  }

  Future<void> receivePush(NotificationItem notification) async {
    // Check if category is enabled in settings
    final s = state.settings;
    if (notification.type == NotificationType.ticket && !s.ticketAlerts) return;
    if (notification.type == NotificationType.reminder24h && !s.reminder24h) return;
    if (notification.type == NotificationType.reminder1h && !s.reminder1h) return;
    if (notification.type == NotificationType.eventUpdate && !s.eventUpdates) return;
    if (notification.type == NotificationType.marketing && !s.marketing) return;

    final updated = [notification, ...state.items];
    state = state.copyWith(
      items: updated,
      latestBanner: notification,
    );
    await _saveToStorage();

    // Also sync to Supabase if authenticated
    try {
      final client = ref.read(backendProvider);
      final uid = client?.auth.currentUser?.id;
      if (client != null && uid != null) {
        await client.from('notifications').insert({
          'user_id': uid,
          'title': notification.title,
          'body': notification.body,
          'type': notification.type.name,
          'payload': notification.payload,
          'is_read': notification.isRead,
        });
      }
    } catch (_) {}
  }

  Future<void> triggerTestPush({
    required NotificationType type,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
  }) async {
    final testItem = NotificationItem(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? _defaultTitle(type),
      body: body ?? _defaultBody(type),
      type: type,
      payload: payload ?? {},
      createdAt: DateTime.now(),
    );
    await receivePush(testItem);
  }

  String _defaultTitle(NotificationType type) {
    switch (type) {
      case NotificationType.ticket:
        return 'Билет успешно оплачен!';
      case NotificationType.reminder24h:
        return 'Напоминание: Мероприятие завтра!';
      case NotificationType.reminder1h:
        return 'Мероприятие начнётся через 1 час!';
      case NotificationType.eventUpdate:
        return 'Обновление мероприятия';
      case NotificationType.marketing:
        return 'Специальная подборка мероприятий';
      default:
        return 'Уведомление EventRadar';
    }
  }

  String _defaultBody(NotificationType type) {
    switch (type) {
      case NotificationType.ticket:
        return 'Ваш электронный билет доступен в профиле. Покажите QR-код при входе.';
      case NotificationType.reminder24h:
        return 'До начала «Jazz in Fergana» осталось 24 часа. Проверьте адрес и билеты.';
      case NotificationType.reminder1h:
        return 'Вход на мероприятие уже открыт. Приготовьте ваш билет.';
      case NotificationType.eventUpdate:
        return 'Организатор уточнил адрес проведения и расписание.';
      case NotificationType.marketing:
        return 'Новые концерты и выставки в вашем городе на этих выходных!';
      default:
        return 'Сервис Push-уведомлений EventRadar активен.';
    }
  }

  Future<void> markAsRead(String id) async {
    final updated = state.items.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    state = state.copyWith(items: updated);
    await _saveToStorage();
  }

  Future<void> markAllAsRead() async {
    final updated = state.items.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(items: updated);
    await _saveToStorage();
  }

  Future<void> clearAll() async {
    state = state.copyWith(items: []);
    await _saveToStorage();
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
      NotificationNotifier.new,
    );

