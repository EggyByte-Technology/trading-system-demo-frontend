import 'package:flutter/material.dart';
import '../../../services/models/risk_models.dart';

class RiskStatusCard extends StatelessWidget {
  final RiskProfile profile;

  const RiskStatusCard({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;

    switch (profile.riskLevel) {
      case 'HIGH':
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        break;
      case 'MEDIUM':
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber;
        break;
      case 'LOW':
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Level: ${profile.riskLevel}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getRiskLevelDescription(profile.riskLevel),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile ID',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(profile.id, style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Updated',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _formatDate(profile.updatedAt),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRiskLevelDescription(String riskLevel) {
    switch (riskLevel) {
      case 'HIGH':
        return 'Your account has high risk factors. Some trading features may be limited.';
      case 'MEDIUM':
        return 'Your account has moderate risk factors. Monitor your trading activity.';
      case 'LOW':
      default:
        return 'Your account is in good standing with low risk.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
