import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../core/config/app_config.dart';

class WebSocketService {
  final AppConfig _appConfig = AppConfig();
  WebSocketChannel? _channel;

  // Controllers for different data types
  final Map<String, StreamController<String>> _channelControllers = {};

  // Connection status
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  // Auth token for user data channels
  String? _authToken;

  WebSocketService() {
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    try {
      final wsUrl = Uri.parse(
        _authToken != null
            ? _appConfig.getUserDataWsUrl(_authToken!)
            : _appConfig.getMarketWsUrl(),
      );

      _channel = WebSocketChannel.connect(wsUrl);
      _isConnected = true;
      _reconnectAttempts = 0;

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // Start ping timer to keep connection alive
      _startPingTimer();

      debugPrint('WebSocket connected: $wsUrl');
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = json.decode(message as String);

      // Process message based on type
      if (data.containsKey('type')) {
        final String type = data['type'];

        if (_channelControllers.containsKey(type)) {
          _channelControllers[type]!.add(message as String);
        }
      }
    } catch (e) {
      debugPrint('Error processing WebSocket message: $e');
    }
  }

  void _onError(error) {
    debugPrint('WebSocket error: $error');
    _isConnected = false;
  }

  void _onDone() {
    debugPrint('WebSocket connection closed');
    _isConnected = false;
    _cancelPingTimer();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    // Cancel any existing reconnect timer
    _reconnectTimer?.cancel();

    if (_reconnectAttempts < _appConfig.wsMaxReconnectAttempts) {
      final delay = _calculateReconnectDelay();
      debugPrint(
        'Scheduling reconnect in $delay seconds (attempt ${_reconnectAttempts + 1})',
      );

      _reconnectTimer = Timer(Duration(seconds: delay), () {
        _reconnectAttempts++;
        _initializeWebSocket();
      });
    } else {
      debugPrint('Max reconnect attempts reached. Giving up.');
    }
  }

  int _calculateReconnectDelay() {
    // Exponential backoff with initial delay
    return _appConfig.wsInitialReconnectDelay * (1 << _reconnectAttempts);
  }

  void _startPingTimer() {
    _pingTimer = Timer.periodic(
      Duration(seconds: _appConfig.wsPingInterval),
      (_) => _sendPing(),
    );
  }

  void _cancelPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _sendPing() {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(json.encode({'type': 'PING'}));
      } catch (e) {
        debugPrint('Error sending ping: $e');
      }
    }
  }

  void setAuthToken(String token) {
    // If token changed, need to reconnect
    if (_authToken != token) {
      _authToken = token;
      _disposeConnection();
      _initializeWebSocket();
    }
  }

  void clearAuthToken() {
    _authToken = null;
    _disposeConnection();
    _initializeWebSocket();
  }

  Stream<String> subscribeToChannel(String channelName) {
    if (!_channelControllers.containsKey(channelName)) {
      _channelControllers[channelName] = StreamController<String>.broadcast();

      // Send subscription message to server
      _subscribe(channelName);
    }

    return _channelControllers[channelName]!.stream;
  }

  void _subscribe(String channelName, {List<String>? symbols}) {
    if (_isConnected && _channel != null) {
      final message = {
        'type': 'SUBSCRIBE',
        'channels': [channelName],
      };

      if (symbols != null && symbols.isNotEmpty) {
        message['symbols'] = symbols;
      }

      _channel!.sink.add(json.encode(message));
    }
  }

  void unsubscribeFromChannel(String channelName) {
    if (_isConnected && _channel != null) {
      final message = {
        'type': 'UNSUBSCRIBE',
        'channels': [channelName],
      };

      _channel!.sink.add(json.encode(message));

      // Close and remove the controller
      _channelControllers[channelName]?.close();
      _channelControllers.remove(channelName);
    }
  }

  void _disposeConnection() {
    _cancelPingTimer();
    _reconnectTimer?.cancel();

    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }

    _isConnected = false;
  }

  void dispose() {
    // Close all stream controllers
    for (var controller in _channelControllers.values) {
      controller.close();
    }
    _channelControllers.clear();

    _disposeConnection();
  }

  bool get isConnected => _isConnected;
}

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
