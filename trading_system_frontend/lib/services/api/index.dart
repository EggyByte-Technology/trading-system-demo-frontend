// Export all API managers for easy importing
import 'api_client.dart';

export 'api_client.dart';
export 'account_manager.dart';
export 'identity_manager.dart';
export 'market_manager.dart';
export 'notification_manager.dart';
export 'risk_manager.dart';
export 'trading_manager.dart';
export 'websocket_manager.dart';

/// Initialize all API services
void initializeApiServices() {
  // Initialize the ApiClient
  ApiClient.initialize();
}
