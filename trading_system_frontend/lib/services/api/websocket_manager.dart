import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../../core/config/app_config.dart';
import '../logger.dart';
import '../models/websocket_models.dart';
import 'api_client.dart';

/// Manager for WebSocket connections and message handling
class WebSocketManager {
  // WebSocket channel
  static WebSocketChannel? _channel;

  // Reconnection timer
  static Timer? _reconnectTimer;

  // Connection status
  static bool _isConnected = false;

  // App configuration
  static final _config = AppConfig();

  // Stream controller for broadcasting messages
  static final _streamController =
      StreamController<WebSocketMessage>.broadcast();

  // Subscribed channels and symbols
  static final _subscribedChannels = <String>[];
  static final _subscribedSymbols = <String>[];

  // Last ping timestamp
  static int _lastPingTime = 0;

  // Ping timer
  static Timer? _pingTimer;

  // Token refresh timer
  static Timer? _tokenRefreshTimer;

  /// Get the WebSocket stream
  static Stream<WebSocketMessage> get stream => _streamController.stream;

  /// Check if WebSocket is connected
  static bool get isConnected => _isConnected;

  /// Initialize WebSocket connection
  static Future<bool> connect() async {
    if (_isConnected) {
      Logger.i('WebSocket already connected');
      return true;
    }

    try {
      // Get authentication token using ApiClient
      final token = await ApiClient.getAuthToken();
      if (token == null) {
        Logger.e('WebSocket connection failed: No authentication token');
        return false;
      }

      // Create WebSocket URL with token
      final wsUrl = _config.getWebsocketUrl(
        'notification',
        '/websocket/ws',
        token: token,
      );

      // Connect to WebSocket
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen for messages
      _channel!.stream.listen(_onMessage, onError: _onError, onDone: _onDone);

      // Start ping timer
      _startPingTimer();

      // Start token refresh timer (refresh token every 50 minutes)
      _startTokenRefreshTimer();

      _isConnected = true;
      Logger.i('WebSocket connected successfully');

      // Resubscribe to channels if needed
      if (_subscribedChannels.isNotEmpty) {
        await _resubscribe();
      }

      return true;
    } catch (e) {
      Logger.e('WebSocket connection failed: $e');
      _scheduleReconnect();
      return false;
    }
  }

  /// Disconnect WebSocket
  static void disconnect() {
    if (!_isConnected) return;

    _stopPingTimer();
    _stopTokenRefreshTimer();
    _channel?.sink.close(ws_status.normalClosure);
    _isConnected = false;

    if (_reconnectTimer != null) {
      _reconnectTimer!.cancel();
      _reconnectTimer = null;
    }

    Logger.i('WebSocket disconnected');
  }

  /// Reconnect with fresh token
  static Future<bool> reconnectWithNewToken() async {
    Logger.i('Reconnecting WebSocket with fresh token...');

    // First disconnect cleanly
    if (_isConnected) {
      _channel?.sink.close(ws_status.normalClosure);
      _isConnected = false;
    }

    // Then connect with new token
    return await connect();
  }

  /// Subscribe to channels
  ///
  /// [channels] List of channels to subscribe to
  /// [symbols] List of symbols to subscribe to
  static Future<bool> subscribe({
    required List<String> channels,
    List<String> symbols = const [],
  }) async {
    if (!_isConnected) {
      final connected = await connect();
      if (!connected) return false;
    }

    try {
      // Add channels and symbols to subscribed lists
      for (final channel in channels) {
        if (!_subscribedChannels.contains(channel)) {
          _subscribedChannels.add(channel);
        }
      }

      for (final symbol in symbols) {
        if (!_subscribedSymbols.contains(symbol)) {
          _subscribedSymbols.add(symbol);
        }
      }

      // Create subscription message
      final message = {
        'type': 'SUBSCRIBE',
        'channels': channels,
        'symbols': symbols,
      };

      // Send subscription message
      _channel!.sink.add(jsonEncode(message));

      Logger.i('Subscribed to channels: $channels, symbols: $symbols');
      return true;
    } catch (e) {
      Logger.e('Failed to subscribe: $e');
      return false;
    }
  }

  /// Unsubscribe from channels
  ///
  /// [channels] List of channels to unsubscribe from
  /// [symbols] List of symbols to unsubscribe from
  static Future<bool> unsubscribe({
    required List<String> channels,
    List<String> symbols = const [],
  }) async {
    if (!_isConnected) return false;

    try {
      // Remove channels and symbols from subscribed lists
      for (final channel in channels) {
        _subscribedChannels.remove(channel);
      }

      for (final symbol in symbols) {
        _subscribedSymbols.remove(symbol);
      }

      // Create unsubscription message
      final message = {
        'type': 'UNSUBSCRIBE',
        'channels': channels,
        'symbols': symbols,
      };

      // Send unsubscription message
      _channel!.sink.add(jsonEncode(message));

      Logger.i('Unsubscribed from channels: $channels, symbols: $symbols');
      return true;
    } catch (e) {
      Logger.e('Failed to unsubscribe: $e');
      return false;
    }
  }

  /// Send ping message to keep connection alive
  static void _sendPing() {
    if (!_isConnected) return;

    try {
      final message = {'type': 'PING'};
      _channel!.sink.add(jsonEncode(message));
      _lastPingTime = DateTime.now().millisecondsSinceEpoch;
    } catch (e) {
      Logger.e('Failed to send ping: $e');
    }
  }

  /// Handle incoming messages
  static void _onMessage(dynamic data) {
    try {
      final Map<String, dynamic> json = jsonDecode(data.toString());

      // Handle pong response
      if (json['type'] == 'PONG') {
        final pingTime = _lastPingTime;
        final pongTime =
            json['time'] as int? ?? DateTime.now().millisecondsSinceEpoch;
        final latency = pongTime - pingTime;

        Logger.d('WebSocket ping latency: $latency ms');
        return;
      }

      // Handle authentication errors
      if (json['type'] == 'ERROR' && json['code'] == 401) {
        Logger.w('WebSocket authentication error: ${json['message']}');

        // Try to refresh token and reconnect
        ApiClient.refreshToken().then((refreshed) {
          if (refreshed) {
            reconnectWithNewToken();
          }
        });

        return;
      }

      // Create WebSocket message based on type
      final WebSocketMessage message;

      switch (json['type']) {
        case 'ticker':
          message = TickerMessage.fromJson(json);
          break;
        case 'depth':
          message = OrderBookMessage.fromJson(json);
          break;
        case 'trade':
          message = TradeMessage.fromJson(json);
          break;
        case 'kline':
          message = KlineMessage.fromJson(json);
          break;
        case 'userData':
          if (json['data']?['eventType'] == 'ORDER_UPDATE') {
            message = OrderUpdateMessage.fromJson(json);
          } else if (json['data']?['eventType'] == 'BALANCE_UPDATE') {
            message = BalanceUpdateMessage.fromJson(json);
          } else {
            message = WebSocketMessage.fromJson(json);
          }
          break;
        default:
          message = WebSocketMessage.fromJson(json);
      }

      // Add message to stream
      _streamController.add(message);
    } catch (e) {
      Logger.e('Failed to parse WebSocket message: $e');
    }
  }

  /// Handle WebSocket errors
  static void _onError(dynamic error) {
    Logger.e('WebSocket error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  /// Handle WebSocket connection closed
  static void _onDone() {
    Logger.i('WebSocket connection closed');
    _isConnected = false;
    _scheduleReconnect();
  }

  /// Schedule WebSocket reconnection
  static void _scheduleReconnect() {
    _stopPingTimer();
    _stopTokenRefreshTimer();

    if (_reconnectTimer != null) {
      _reconnectTimer!.cancel();
    }

    _reconnectTimer = Timer(const Duration(seconds: 5), () async {
      Logger.i('Attempting to reconnect WebSocket...');
      await connect();
    });
  }

  /// Resubscribe to previously subscribed channels
  static Future<bool> _resubscribe() async {
    if (_subscribedChannels.isEmpty) return true;

    return subscribe(
      channels: List.from(_subscribedChannels),
      symbols: List.from(_subscribedSymbols),
    );
  }

  /// Start ping timer
  static void _startPingTimer() {
    _stopPingTimer();

    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _sendPing();
    });
  }

  /// Stop ping timer
  static void _stopPingTimer() {
    if (_pingTimer != null) {
      _pingTimer!.cancel();
      _pingTimer = null;
    }
  }

  /// Start token refresh timer
  static void _startTokenRefreshTimer() {
    _stopTokenRefreshTimer();

    // Refresh every 50 minutes (JWT expires in 60 minutes)
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 50), (
      timer,
    ) async {
      Logger.i('Refreshing WebSocket auth token...');
      final refreshed = await ApiClient.refreshToken();
      if (refreshed) {
        await reconnectWithNewToken();
      }
    });
  }

  /// Stop token refresh timer
  static void _stopTokenRefreshTimer() {
    if (_tokenRefreshTimer != null) {
      _tokenRefreshTimer!.cancel();
      _tokenRefreshTimer = null;
    }
  }

  /// Dispose WebSocket manager
  static void dispose() {
    disconnect();
    _streamController.close();
  }
}
