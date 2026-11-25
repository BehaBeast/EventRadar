import 'dart:convert';

enum NotificationType {
  info,
  ticket,
  reminder24h,
  reminder1h,
  eventUpdate,
  marketing,
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.payload = const {},
    required this.createdAt,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type.name,
    'payload': payload,
    'created_at': createdAt.toIso8601String(),
    'is_read': isRead,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      payload: json['payload'] is Map ? Map<String, dynamic>.from(json['payload'] as Map) : {},
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  static NotificationType _parseType(String? str) {
    switch (str) {
      case 'ticket':
        return NotificationType.ticket;
      case 'reminder_24h':
      case 'reminder24h':
        return NotificationType.reminder24h;
      case 'reminder_1h':
      case 'reminder1h':
        return NotificationType.reminder1h;
      case 'event_update':
      case 'eventUpdate':
        return NotificationType.eventUpdate;
      case 'marketing':
        return NotificationType.marketing;
      default:
        return NotificationType.info;
    }
  }
}

