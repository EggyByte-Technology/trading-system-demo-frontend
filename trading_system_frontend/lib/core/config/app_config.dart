import 'package:flutter/foundation.dart';

/// Application configuration class
/// Contains environment-specific settings and service URLs
class AppConfig {
  /// Singleton instance
  static final AppConfig _instance = AppConfig._internal();

  /// Factory constructor to return the singleton instance
  factory AppConfig() => _instance;

  /// Private constructor for singleton pattern
  AppConfig._internal() {
    // Initialize with test environment by default
    initialize(Environment.test);
  }

  /// Current environment
  late Environment _environment;

  /// API Gateway base URL
  late String apiBaseUrl;

  /// WebSocket base URL
  late String wsBaseUrl;

  /// WebSocket ping interval in seconds
  int wsPingInterval = 30;

  /// WebSocket connection timeout in seconds
  int wsConnectionTimeout = 10;

  /// WebSocket max reconnect attempts
  int wsMaxReconnectAttempts = 5;

  /// WebSocket initial reconnect delay in seconds
  int wsInitialReconnectDelay = 2;

  /// Authentication service path
  final String authPath = '/auth';

  /// Account service path
  final String accountPath = '/account';

  /// Order service path
  final String orderPath = '/order';

  /// Market service path
  final String marketPath = '/trade';

  /// Trade service path
  final String tradePath = '/trade';

  /// Risk service path
  final String riskPath = '/risk';

  /// JWT token storage key
  final String tokenKey = 'auth_token';

  /// Refresh token storage key
  final String refreshTokenKey = 'refresh_token';

  /// Map of service hosts
  late Map<String, String> serviceHosts;

  /// Map of WebSocket hosts
  late Map<String, String> wsHosts;

  /// Get the base URL for a given service
  String getServiceBaseUrl(String service) {
    return serviceHosts[service] ?? apiBaseUrl;
  }

  /// Get the base WebSocket URL for a given service
  String getWsBaseUrl(String service) {
    return wsHosts[service] ?? wsBaseUrl;
  }

  /// Get the full URL for a given service and endpoint
  String getServiceUrl(String service, String endpoint) {
    final base = getServiceBaseUrl(service);
    return '$base$endpoint';
  }

  /// Get the full WebSocket URL for a given service and endpoint
  String getWebsocketUrl(String service, String endpoint, {String? token}) {
    final base = getWsBaseUrl(service);
    final url = '$base$endpoint';
    return token != null ? '$url?token=$token' : url;
  }

  /// Initialize the configuration based on the environment
  void initialize(Environment environment) {
    _environment = environment;

    switch (environment) {
      case Environment.test:
        // Per-service hosts for local development
        serviceHosts = {
          'account': 'http://account.trading-system.local',
          'identity': 'http://identity.trading-system.local',
          'market': 'http://market-data.trading-system.local',
          'notification': 'http://notification.trading-system.local',
          'risk': 'http://risk.trading-system.local',
          'trading': 'http://trading.trading-system.local',
        };

        // Per-service WebSocket hosts
        wsHosts = {
          'account': 'ws://account.trading-system.local',
          'identity': 'ws://identity.trading-system.local',
          'market': 'ws://market-data.trading-system.local',
          'notification': 'ws://notification.trading-system.local',
          'risk': 'ws://risk.trading-system.local',
          'trading': 'ws://trading.trading-system.local',
        };

        apiBaseUrl = 'http://localhost:1234'; // fallback
        wsBaseUrl = 'ws://localhost:1234/ws'; // fallback
        wsPingInterval = 15;
        wsConnectionTimeout = 5;
        break;
      case Environment.production:
        serviceHosts = {
          'account': 'https://account.trading-system.com',
          'identity': 'https://identity.trading-system.com',
          'market': 'https://market-data.trading-system.com',
          'notification': 'https://notification.trading-system.com',
          'risk': 'https://risk.trading-system.com',
          'trading': 'https://trading.trading-system.com',
        };

        // Per-service WebSocket hosts for production
        wsHosts = {
          'account': 'wss://account.trading-system.com',
          'identity': 'wss://identity.trading-system.com',
          'market': 'wss://market-data.trading-system.com',
          'notification': 'wss://notification.trading-system.com',
          'risk': 'wss://risk.trading-system.com',
          'trading': 'wss://trading.trading-system.com',
        };

        apiBaseUrl = 'https://api.trading-system.com';
        wsBaseUrl = 'wss://api.trading-system.com/ws';
        wsPingInterval = 30;
        wsConnectionTimeout = 10;
        break;
      case Environment.staging:
        serviceHosts = {
          'account': 'https://staging-account.trading-system.com',
          'identity': 'https://staging-identity.trading-system.com',
          'market': 'https://staging-market-data.trading-system.com',
          'notification': 'https://staging-notification.trading-system.com',
          'risk': 'https://staging-risk.trading-system.com',
          'trading': 'https://staging-trading.trading-system.com',
        };

        // Per-service WebSocket hosts for staging
        wsHosts = {
          'account': 'wss://staging-account.trading-system.com',
          'identity': 'wss://staging-identity.trading-system.com',
          'market': 'wss://staging-market-data.trading-system.com',
          'notification': 'wss://staging-notification.trading-system.com',
          'risk': 'wss://staging-risk.trading-system.com',
          'trading': 'wss://staging-trading.trading-system.com',
        };

        apiBaseUrl = 'https://staging-api.trading-system.com';
        wsBaseUrl = 'wss://staging-api.trading-system.com/ws';
        wsPingInterval = 20;
        wsConnectionTimeout = 8;
        break;
    }

    debugPrint('AppConfig initialized with environment: $_environment');
    debugPrint('Service hosts:');
    serviceHosts.forEach((k, v) => debugPrint('  $k: $v'));
    debugPrint('WebSocket hosts:');
    wsHosts.forEach((k, v) => debugPrint('  $k: $v'));
    debugPrint('API Gateway URL: $apiBaseUrl');
    debugPrint('WebSocket URL: $wsBaseUrl');
  }

  /// Get the auth URL for the given endpoint
  String getAuthUrl(String endpoint) {
    return getServiceUrl('identity', '/auth$endpoint');
  }

  /// Get the account service URL for the given endpoint
  String getAccountUrl(String endpoint) {
    return getServiceUrl('account', '/account$endpoint');
  }

  /// Get the order service URL for the given endpoint
  String getOrderUrl(String endpoint) {
    return getServiceUrl('trading', '/order$endpoint');
  }

  /// Get the trade service URL for the given endpoint
  String getTradeUrl(String endpoint) {
    return getServiceUrl('trading', '/trade$endpoint');
  }

  /// Get the market data URL for the given endpoint
  String getMarketUrl(String endpoint) {
    return getServiceUrl('market', '/market$endpoint');
  }

  /// Get the risk service URL for the given endpoint
  String getRiskUrl(String endpoint) {
    return getServiceUrl('risk', '/risk$endpoint');
  }

  /// Get the WebSocket URL with a token
  String getWsUrl(String token) {
    return getWebsocketUrl('notification', '/websocket/ws', token: token);
  }

  /// Get the WebSocket URL for market data
  String getMarketWsUrl() {
    return getWebsocketUrl('market', '/websocket/market');
  }

  /// Get the WebSocket URL for user data (authenticated)
  String getUserDataWsUrl(String token) {
    return getWebsocketUrl('notification', '/websocket/ws', token: token);
  }

  /// Get the current environment
  Environment get environment => _environment;

  /// Check if we're in debug mode (test or staging)
  bool get isDebugMode => _environment != Environment.production;
}

/// Application environments
enum Environment { test, production, staging }
