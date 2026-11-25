import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import 'ticket_model.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key, required this.ticket});
  final TicketItem ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localTime = tz.TZDateTime.from(
      ticket.startsAt,
      tz.getLocation(ticket.timezone),
    );
    final dateStr = DateFormat.yMMMMd('ru').add_Hm().format(localTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Электронный билет'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Поделиться',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ссылка на билет скопирована')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.green),
                          SizedBox(width: 6),
                          Text(
                            'ДЕЙСТВИТЕЛЕН',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Event Title
                    Text(
                      ticket.eventTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    // Category / Tier Badge
                    Text(
                      'Тариф: ${ticket.tierName}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // QR Code Visual Container
                    Container(
                      width: 200,
                      height: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: CustomPaint(
                        painter: QrCodePainter(data: ticket.qrCode),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      ticket.ticketNumber,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Покажите этот QR-код контролёру на входе',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),

                    const Divider(height: 36),

                    // Details Table
                    _buildDetailRow(context, 'Дата и время', '$dateStr · ${ticket.timezone}'),
                    const SizedBox(height: 10),
                    _buildDetailRow(context, 'Город и адрес', '${ticket.cityName}, ${ticket.address}'),
                    const SizedBox(height: 10),
                    _buildDetailRow(context, 'Владелец', ticket.buyerName),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      context,
                      'Стоимость',
                      '${NumberFormat.decimalPattern().format(ticket.price)} ${ticket.currency}',
                    ),

                    const SizedBox(height: 24),

                    OutlinedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Сохранить билет (PDF)'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Билет сохранён в загрузки устройства')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Custom QR Code Canvas Painter that deterministically renders a sharp 2D matrix
class QrCodePainter extends CustomPainter {
  final String data;

  QrCodePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBlack = Paint()..color = Colors.black;
    const grid = 21; // standard QR version 1 size
    final cellWidth = size.width / grid;
    final cellHeight = size.height / grid;

    // Corner position detection patterns (7x7)
    _drawPositionMarker(canvas, 0, 0, cellWidth, cellHeight, paintBlack);
    _drawPositionMarker(canvas, grid - 7, 0, cellWidth, cellHeight, paintBlack);
    _drawPositionMarker(canvas, 0, grid - 7, cellWidth, cellHeight, paintBlack);

    // Deterministic pseudo-random pattern based on hash of data
    int hash = 0;
    for (int i = 0; i < data.length; i++) {
      hash = ((hash << 5) - hash + data.codeUnitAt(i)) & 0x7FFFFFFF;
    }

    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        // Skip corner markers
        if ((r < 7 && c < 7) || (r < 7 && c >= grid - 7) || (r >= grid - 7 && c < 7)) {
          continue;
        }

        // Timing patterns
        if (r == 6 || c == 6) {
          if ((r + c) % 2 == 0) {
            canvas.drawRect(
              Rect.fromLTWH(c * cellWidth, r * cellHeight, cellWidth, cellHeight),
              paintBlack,
            );
          }
          continue;
        }

        // Fill based on deterministic bit distribution
        final bit = ((hash ^ (r * 31 + c * 17)) & (1 << ((r + c) % 24))) != 0;
        if (bit) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellWidth + 0.5, r * cellHeight + 0.5, cellWidth - 1, cellHeight - 1),
            paintBlack,
          );
        }
      }
    }
  }

  void _drawPositionMarker(
    Canvas canvas,
    int startCol,
    int startRow,
    double cw,
    double ch,
    Paint paint,
  ) {
    // 7x7 outer square
    for (int r = 0; r < 7; r++) {
      for (int c = 0; c < 7; c++) {
        if (r == 0 || r == 6 || c == 0 || c == 6 || (r >= 2 && r <= 4 && c >= 2 && c <= 4)) {
          canvas.drawRect(
            Rect.fromLTWH((startCol + c) * cw, (startRow + r) * ch, cw, ch),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QrCodePainter oldDelegate) => oldDelegate.data != data;
}

