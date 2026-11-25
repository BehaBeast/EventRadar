import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../catalog/event.dart';
import '../notifications/notification_model.dart';
import '../notifications/notification_service.dart';
import 'payment_config.dart';
import 'payment_gateway.dart';
import 'ticket_model.dart';
import 'ticket_screen.dart';

class CheckoutSheet extends ConsumerStatefulWidget {
  const CheckoutSheet({super.key, required this.event});
  final RadarEvent event;

  @override
  ConsumerState<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<CheckoutSheet> {
  int _quantity = 1;
  int _selectedTierIndex = 0;
  PaymentMethod _selectedMethod = PaymentMethod.payme;
  bool _processing = false;
  String? _errorMessage;

  late final List<TicketTier> _tiers = [
    TicketTier(
      id: 'tier_standard_${widget.event.id}',
      eventId: widget.event.id,
      name: 'Входной билет',
      description: 'Доступ на общую площадку мероприятия',
      price: 100000,
    ),
    TicketTier(
      id: 'tier_fan_${widget.event.id}',
      eventId: widget.event.id,
      name: 'Фан-зона',
      description: 'Ближе к сцене, приоритетный вход',
      price: 180000,
    ),
    TicketTier(
      id: 'tier_vip_${widget.event.id}',
      eventId: widget.event.id,
      name: 'VIP ложа',
      description: 'Отдельный вход, напитки, лучшие места',
      price: 350000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedTier = _tiers[_selectedTierIndex];
    final subtotal = selectedTier.price * _quantity;
    final platformFee = (subtotal * 0.05).round(); // 5% absorbed by organizer
    final total = subtotal;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Покупка билетов',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.event.title,
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),

            // Select Tier
            Text(
              'Категория билета',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List.generate(_tiers.length, (i) {
              final tier = _tiers[i];
              final isSelected = _selectedTierIndex == i;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                color: isSelected
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                child: ListTile(
                  title: Text(tier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(tier.description),
                  trailing: Text(
                    '${NumberFormat.decimalPattern().format(tier.price)} сум',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () => setState(() => _selectedTierIndex = i),
                ),
              );
            }),

            const SizedBox(height: 12),

            // Quantity selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Количество билетов',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.remove),
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '$_quantity',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add),
                      onPressed: _quantity < 10 ? () => setState(() => _quantity++) : null,
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 24),

            // Payment Methods
            Text(
              'Способ оплаты',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildPaymentMethodTile(
              PaymentMethod.payme,
              'Payme',
              'Uzcard / Humo / Visa',
              Icons.account_balance_wallet,
              theme,
            ),
            _buildPaymentMethodTile(
              PaymentMethod.click,
              'Click',
              'Click Up / Evolution',
              Icons.touch_app,
              theme,
            ),
            _buildPaymentMethodTile(
              PaymentMethod.card,
              'Банковская карта',
              'Uzcard, Humo, Visa, Mastercard',
              Icons.credit_card,
              theme,
            ),
            _buildPaymentMethodTile(
              PaymentMethod.test,
              'Тестовый шлюз (Песочница)',
              'Мгновенная оплата для проверки системы',
              Icons.developer_mode,
              theme,
            ),

            const SizedBox(height: 16),

            // Price Breakdown Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Билеты ($_quantity шт.)', style: theme.textTheme.bodyMedium),
                      Text('${NumberFormat.decimalPattern().format(subtotal)} сум'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Сервисный сбор EventRadar (5%)', style: theme.textTheme.bodySmall),
                      Text(
                        '0 сум (включён)',
                        style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Итого к оплате',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${NumberFormat.decimalPattern().format(total)} сум',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],

            const SizedBox(height: 20),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _processing ? null : _handlePayment,
                child: _processing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Оплатить ${NumberFormat.decimalPattern().format(total)} сум',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
    ThemeData theme,
  ) {
    final isSelected = _selectedMethod == method;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0,
      color: isSelected
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
        ),
      ),
      child: RadioListTile<PaymentMethod>(
        value: method,
        groupValue: _selectedMethod,
        onChanged: (v) => setState(() => _selectedMethod = v!),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        secondary: Icon(icon, color: isSelected ? theme.colorScheme.primary : Colors.grey),
      ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() {
      _processing = true;
      _errorMessage = null;
    });

    try {
      final selectedTier = _tiers[_selectedTierIndex];
      final total = selectedTier.price * _quantity;
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

      final gateway = ref.read(paymentConfigProvider.notifier).getGateway(_selectedMethod);

      final req = PaymentRequest(
        orderId: orderId,
        eventId: widget.event.id,
        eventTitle: widget.event.title,
        amount: total,
        buyerEmail: 'user@eventradar.uz',
        buyerName: 'Пользователь EventRadar',
      );

      final result = await gateway.processPayment(req);

      if (!result.success) {
        throw StateError(result.errorMessage ?? 'Ошибка обработки платежа');
      }

      // Generate Ticket Items
      final List<TicketItem> newTickets = [];
      final now = DateTime.now();
      for (int i = 0; i < _quantity; i++) {
        final ticketNum = 'ER-${(10000000 + (now.microsecondsSinceEpoch % 89999999) + i)}';
        final ticket = TicketItem(
          id: 'ticket_${now.millisecondsSinceEpoch}_$i',
          orderId: orderId,
          eventId: widget.event.id,
          eventTitle: widget.event.title,
          cityName: widget.event.cityName,
          address: widget.event.address,
          startsAt: widget.event.startsAt,
          timezone: widget.event.timezone,
          tierName: selectedTier.name,
          price: selectedTier.price,
          currency: selectedTier.currency,
          ticketNumber: ticketNum,
          qrCode: 'EVENTRADAR:TICKET:$ticketNum:$orderId',
          buyerName: 'Пользователь EventRadar',
          purchasedAt: now,
        );
        newTickets.add(ticket);
      }

      // Add to store
      await ref.read(userTicketsProvider.notifier).addTickets(newTickets);

      // Trigger instant push notification
      await ref.read(notificationProvider.notifier).receivePush(
        NotificationItem(
          id: 'notif_purchase_$orderId',
          title: 'Билет успешно оплачен!',
          body: 'Заказ на «${widget.event.title}» ($total сум) оплачен через ${gateway.name}. Ваши билеты доступны в профиле.',
          type: NotificationType.ticket,
          payload: {'order_id': orderId, 'event_id': widget.event.id},
          createdAt: now,
        ),
      );

      if (mounted) {
        Navigator.pop(context); // close bottom sheet

        // Show ticket
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TicketScreen(ticket: newTickets.first),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Не удалось завершить платёж: $e';
          _processing = false;
        });
      }
    }
  }
}

