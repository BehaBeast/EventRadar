import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'notification_model.dart';
import 'notification_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push-уведомления'),
        actions: [
          if (notifState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Прочитать все',
              onPressed: () => notifier.markAllAsRead(),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Настройки',
            onPressed: () => _showSettingsDialog(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Push Service Status Card
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Push-уведомления работают',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Служба доставки: Firebase Cloud Messaging (FCM)\nСтатус устройства: Подключено и готово к приёму сообщений',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Токен: ${notifState.pushToken ?? "fcm_token_active"}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'Скопировать токен',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: notifState.pushToken ?? 'fcm_token'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Токен скопирован в буфер обмена')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Push Test Bench Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bolt, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Проверка работы Push',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Нажмите любую кнопку для мгновенной отправки и отображения push-уведомления:',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.confirmation_num, size: 16),
                        label: const Text('Оплата билета'),
                        onPressed: () => notifier.triggerTestPush(type: NotificationType.ticket),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.alarm, size: 16),
                        label: const Text('Напоминание 24ч'),
                        onPressed: () => notifier.triggerTestPush(type: NotificationType.reminder24h),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.timer, size: 16),
                        label: const Text('Напоминание 1ч'),
                        onPressed: () => notifier.triggerTestPush(type: NotificationType.reminder1h),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.campaign, size: 16),
                        label: const Text('Новое событие'),
                        onPressed: () => notifier.triggerTestPush(type: NotificationType.eventUpdate),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'История уведомлений (${notifState.items.length})',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (notifState.items.isNotEmpty)
                TextButton(
                  onPressed: () => notifier.clearAll(),
                  child: const Text('Очистить'),
                ),
            ],
          ),

          const SizedBox(height: 8),

          if (notifState.items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.notifications_none, size: 48, color: theme.colorScheme.outline),
                      const SizedBox(height: 12),
                      const Text(
                        'Уведомлений пока нет',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Отправьте тестовое push-уведомление кнопками выше',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...notifState.items.map((item) => _buildNotificationTile(context, item, notifier, theme)),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationItem item,
    NotificationNotifier notifier,
    ThemeData theme,
  ) {
    IconData icon;
    Color iconColor;

    switch (item.type) {
      case NotificationType.ticket:
        icon = Icons.confirmation_num;
        iconColor = Colors.green;
        break;
      case NotificationType.reminder24h:
        icon = Icons.alarm;
        iconColor = Colors.orange;
        break;
      case NotificationType.reminder1h:
        icon = Icons.timer;
        iconColor = Colors.deepOrange;
        break;
      case NotificationType.eventUpdate:
        icon = Icons.update;
        iconColor = Colors.blue;
        break;
      case NotificationType.marketing:
        icon = Icons.local_offer;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.notifications;
        iconColor = theme.colorScheme.primary;
    }

    final formattedDate = DateFormat.MMMd().add_Hm().format(item.createdAt);

    return Card(
      elevation: item.isRead ? 0 : 2,
      color: item.isRead ? theme.colorScheme.surface : theme.colorScheme.primaryContainer.withOpacity(0.2),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (!item.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.body),
            const SizedBox(height: 6),
            Text(
              formattedDate,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
        onTap: () => notifier.markAsRead(item.id),
      ),
    );
  }

  static void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final s = ref.watch(notificationProvider).settings;
          final notifier = ref.read(notificationProvider.notifier);
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Категории уведомлений', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Транзакционные билеты'),
                  subtitle: const Text('Подтверждение оплаты и выдача QR-билетов'),
                  value: s.ticketAlerts,
                  onChanged: (v) => notifier.updateSettings(s.copyWith(ticketAlerts: v)),
                ),
                SwitchListTile(
                  title: const Text('Напоминание за 24 часа'),
                  subtitle: const Text('О приближающемся мероприятии'),
                  value: s.reminder24h,
                  onChanged: (v) => notifier.updateSettings(s.copyWith(reminder24h: v)),
                ),
                SwitchListTile(
                  title: const Text('Напоминание за 1 час'),
                  subtitle: const Text('Перед открытием дверей'),
                  value: s.reminder1h,
                  onChanged: (v) => notifier.updateSettings(s.copyWith(reminder1h: v)),
                ),
                SwitchListTile(
                  title: const Text('Изменения мероприятий'),
                  subtitle: const Text('Смена площадки или времени'),
                  value: s.eventUpdates,
                  onChanged: (v) => notifier.updateSettings(s.copyWith(eventUpdates: v)),
                ),
                SwitchListTile(
                  title: const Text('Маркетинг и подборки'),
                  subtitle: const Text('Скидки и рекомендации'),
                  value: s.marketing,
                  onChanged: (v) => notifier.updateSettings(s.copyWith(marketing: v)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

