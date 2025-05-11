import 'package:flutter/material.dart';
import '../../../services/models/risk_models.dart';

class TradingLimitsCard extends StatelessWidget {
  final TradingLimits limits;

  const TradingLimitsCard({Key? key, required this.limits}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLimitRow(
              context,
              'Daily Withdrawal Limit',
              '\$${limits.dailyWithdrawalLimit.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            _buildLimitRow(
              context,
              'Single Order Limit',
              '\$${limits.singleOrderLimit.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            _buildLimitRow(
              context,
              'Daily Trading Limit',
              '\$${limits.dailyTradingLimit.toStringAsFixed(2)}',
            ),

            if (limits.assetSpecificLimits.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text('Asset-Specific Limits', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...limits.assetSpecificLimits.entries.map(
                (entry) => _buildLimitRow(
                  context,
                  entry.key,
                  '\$${entry.value.toStringAsFixed(2)}',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLimitRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
