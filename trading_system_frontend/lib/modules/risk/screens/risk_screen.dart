import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/risk_manager.dart';
import '../../../services/models/risk_models.dart';
import '../providers/risk_provider.dart';
import '../widgets/risk_status_card.dart';
import '../widgets/trading_limits_card.dart';
import '../widgets/risk_alert_card.dart';

class RiskScreen extends ConsumerWidget {
  const RiskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskProfileAsync = ref.watch(riskProfileProvider);
    final riskAlertsAsync = ref.watch(riskAlertsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Risk Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(riskProfileProvider);
              ref.refresh(riskAlertsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(riskProfileProvider);
          ref.refresh(riskAlertsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Risk Status', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),

              // Risk Profile
              riskProfileAsync.when(
                data: (profile) => RiskStatusCard(profile: profile),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('Error loading risk profile: $error')),
              ),

              const SizedBox(height: 24),

              Text('Trading Limits', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),

              // Trading Limits
              riskProfileAsync.when(
                data: (profile) => TradingLimitsCard(limits: profile.limits),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('Error loading trading limits: $error')),
              ),

              const SizedBox(height: 24),

              Text('Active Alerts', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),

              // Risk Alerts
              riskAlertsAsync.when(
                data: (alerts) {
                  if (alerts.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No active risk alerts',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: alerts
                        .map(
                          (alert) => RiskAlertCard(
                            alert: alert,
                            onAcknowledge: () =>
                                _acknowledgeAlert(context, ref, alert.id),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('Error loading risk alerts: $error')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acknowledgeAlert(
    BuildContext context,
    WidgetRef ref,
    String alertId,
  ) async {
    try {
      await RiskManager.acknowledgeAlert(alertId);

      // Refresh alerts
      ref.refresh(riskAlertsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alert acknowledged'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to acknowledge alert: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
