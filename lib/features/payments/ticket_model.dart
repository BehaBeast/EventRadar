import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/backend.dart';
import '../../core/settings.dart';

class TicketTier {
  final String id;
  final String eventId;
  final String name;
  final String description;
  final int price; // in UZS
  final String currency;
  final int totalQuantity;
  final int soldQuantity;

  const TicketTier({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'UZS',
    this.totalQuantity = 100,
    this.soldQuantity = 0,
  });

  bool get isSoldOut => soldQuantity >= totalQuantity;
  int get availableQuantity => totalQuantity - soldQuantity;

  factory TicketTier.fromJson(Map<String, dynamic> json) => TicketTier(
    id: json['id'] as String? ?? 'tier_std',
    eventId: json['event_id'] as String? ?? '',
    name: json['name'] as String? ?? 'Входной билет',
    description: json['description'] as String? ?? '',
    price: (json['price'] as num?)?.toInt() ?? 100000,
    currency: json['currency'] as String? ?? 'UZS',
    totalQuantity: (json['quantity_total'] as num?)?.toInt() ?? 100,
    soldQuantity: (json['quantity_sold'] as num?)?.toInt() ?? 0,
  );
}

class TicketItem {
  final String id;
  final String orderId;
  final String eventId;
  final String eventTitle;
  final String cityName;
  final String address;
  final DateTime startsAt;
  final String timezone;
  final String tierName;
  final int price;
  final String currency;
  final String ticketNumber;
  final String qrCode;
  final String status; // 'valid', 'used', 'cancelled'
  final String buyerName;
  final DateTime purchasedAt;

  const TicketItem({
    required this.id,
    required this.orderId,
    required this.eventId,
    required this.eventTitle,
    required this.cityName,
    required this.address,
    required this.startsAt,
    required this.timezone,
    required this.tierName,
    required this.price,
    this.currency = 'UZS',
    required this.ticketNumber,
    required this.qrCode,
    this.status = 'valid',
    required this.buyerName,
    required this.purchasedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'event_id': eventId,
    'event_title': eventTitle,
    'city_name': cityName,
    'address': address,
    'starts_at': startsAt.toIso8601String(),
    'timezone': timezone,
    'tier_name': tierName,
    'price': price,
    'currency': currency,
    'ticket_number': ticketNumber,
    'qr_code': qrCode,
    'status': status,
    'buyer_name': buyerName,
    'purchased_at': purchasedAt.toIso8601String(),
  };

  factory TicketItem.fromJson(Map<String, dynamic> json) => TicketItem(
    id: json['id'] as String? ?? 't_${DateTime.now().millisecondsSinceEpoch}',
    orderId: json['order_id'] as String? ?? '',
    eventId: json['event_id'] as String? ?? '',
    eventTitle: json['event_title'] as String? ?? 'Мероприятие',
    cityName: json['city_name'] as String? ?? '',
    address: json['address'] as String? ?? '',
    startsAt: json['starts_at'] != null ? DateTime.tryParse(json['starts_at'].toString()) ?? DateTime.now() : DateTime.now(),
    timezone: json['timezone'] as String? ?? 'Asia/Tashkent',
    tierName: json['tier_name'] as String? ?? 'Стандарт',
    price: (json['price'] as num?)?.toInt() ?? 100000,
    currency: json['currency'] as String? ?? 'UZS',
    ticketNumber: json['ticket_number'] as String? ?? 'ER-TICKET',
    qrCode: json['qr_code'] as String? ?? 'EVENTRADAR:TICKET:ER-TICKET',
    status: json['status'] as String? ?? 'valid',
    buyerName: json['buyer_name'] as String? ?? 'Гость',
    purchasedAt: json['purchased_at'] != null ? DateTime.tryParse(json['purchased_at'].toString()) ?? DateTime.now() : DateTime.now(),
  );
}

class TicketsNotifier extends Notifier<List<TicketItem>> {
  static const _storageKey = 'eventradar_user_tickets';

  @override
  List<TicketItem> build() {
    final prefs = ref.watch(preferencesProvider);
    final raw = prefs.getStringList(_storageKey);
    if (raw != null) {
      try {
        return raw.map((s) => TicketItem.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> addTickets(List<TicketItem> newTickets) async {
    final updated = [...newTickets, ...state];
    state = updated;
    final prefs = ref.read(preferencesProvider);
    await prefs.setStringList(_storageKey, updated.map((t) => jsonEncode(t.toJson())).toList());

    // Also sync to Supabase if authenticated
    try {
      final client = ref.read(backendProvider);
      final uid = client?.auth.currentUser?.id;
      if (client != null && uid != null) {
        for (final t in newTickets) {
          await client.from('tickets').upsert({
            'id': t.id,
            'order_id': t.orderId,
            'user_id': uid,
            'event_id': t.eventId,
            'ticket_number': t.ticketNumber,
            'qr_code': t.qrCode,
            'status': t.status,
          });
        }
      }
    } catch (_) {}
  }

  Future<void> clearAll() async {
    state = [];
    final prefs = ref.read(preferencesProvider);
    await prefs.remove(_storageKey);
  }
}

final userTicketsProvider =
    NotifierProvider<TicketsNotifier, List<TicketItem>>(
      TicketsNotifier.new,
    );

