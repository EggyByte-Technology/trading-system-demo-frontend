import 'package:flutter/material.dart';
import '../../../services/models/risk_models.dart';

class RiskAlertCard extends StatelessWidget {
  final RiskAlert alert;
  final VoidCallback onAcknowledge;

  const RiskAlertCard({
    Key? key,
    required this.alert,
    required this.onAcknowledge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color severityColor;
    IconData severityIcon;

    switch (alert.severity) {
      case 'CRITICAL':
        severityColor = Colors.red.shade900;
        severityIcon = Icons.error;
        break;
      case 'HIGH':
        severityColor = Colors.red;
        severityIcon = Icons.warning;
        break;
      case 'MEDIUM':
        severityColor = Colors.orange;
        severityIcon = Icons.warning_amber;
        break;
      case 'LOW':
      default:
        severityColor = Colors.blue;
        severityIcon = Icons.info;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            leading: Icon(severityIcon, color: severityColor, size: 36),
            title: Text(
              alert.type,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(alert.message, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  'Created: ${_formatDate(alert.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!alert.isAcknowledged)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onAcknowledge,
                    child: const Text('ACKNOWLEDGE'),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Acknowledged: ${_formatDate(alert.acknowledgedAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
