import '../models/risk_models.dart';
import 'api_client.dart';

/// Manager for risk-related API calls
class RiskManager {
  /// Get user risk status
  static Future<RiskProfile> getRiskStatus() async {
    final response = await ApiClient.get('risk', '/risk/status');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get risk status');
    }

    return RiskProfile.fromJson(response.data);
  }

  /// Get user trading limits
  static Future<TradingLimits> getTradingLimits() async {
    final response = await ApiClient.get('risk', '/risk/limits');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get trading limits');
    }

    return TradingLimits.fromJson(response.data);
  }

  /// Get active risk alerts
  static Future<List<RiskAlert>> getActiveAlerts() async {
    final response = await ApiClient.get('risk', '/risk/alerts');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get active alerts');
    }

    final List<dynamic> alerts = response.data;
    return alerts.map((alert) => RiskAlert.fromJson(alert)).toList();
  }

  /// Acknowledge a risk alert
  ///
  /// [alertId] Alert ID to acknowledge
  static Future<void> acknowledgeAlert(String alertId) async {
    final response = await ApiClient.post(
      'risk',
      '/risk/alerts/$alertId/acknowledge',
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to acknowledge alert');
    }
  }

  /// Get active risk rules (Admin only)
  static Future<List<RiskRule>> getActiveRules() async {
    final response = await ApiClient.get('risk', '/risk/rules');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get active rules');
    }

    final List<dynamic> rules = response.data;
    return rules.map((rule) => RiskRule.fromJson(rule)).toList();
  }
}
