import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/risk_manager.dart';
import '../../../services/models/risk_models.dart';

/// Provider for fetching risk profile
final riskProfileProvider = FutureProvider<RiskProfile>((ref) async {
  return RiskManager.getRiskStatus();
});

/// Provider for fetching trading limits
final tradingLimitsProvider = FutureProvider<TradingLimits>((ref) async {
  return RiskManager.getTradingLimits();
});

/// Provider for fetching active risk alerts
final riskAlertsProvider = FutureProvider<List<RiskAlert>>((ref) async {
  return RiskManager.getActiveAlerts();
});
