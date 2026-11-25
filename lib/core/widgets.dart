import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.message,
    this.retry,
    this.icon = Icons.radar,
  });
  final String message;
  final VoidCallback? retry;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (retry != null) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: retry,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ],
      ),
    ),
  );
}
