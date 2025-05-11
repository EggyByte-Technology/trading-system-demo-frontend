import 'dart:convert';

/// Base WebSocket message class
class WebSocketMessage {
  final String type;
  final String? symbol;
  final int timestamp;
  final dynamic data;

  WebSocketMessage({
    required this.type,
    this.symbol,
    required this.timestamp,
    this.data,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] ?? '',
      symbol: json['symbol'],
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (symbol != null) 'symbol': symbol,
      'timestamp': timestamp,
      if (data != null) 'data': data,
    };
  }
}

/// Ticker data message
class TickerMessage extends WebSocketMessage {
  TickerMessage({
    required String symbol,
    required int timestamp,
    required Map<String, dynamic> data,
  }) : super(type: 'ticker', symbol: symbol, timestamp: timestamp, data: data);

  factory TickerMessage.fromJson(Map<String, dynamic> json) {
    return TickerMessage(
      symbol: json['symbol'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      data: json['data'] ?? {},
    );
  }

  double get lastPrice => (data['lastPrice'] as num?)?.toDouble() ?? 0.0;
  double get priceChange => (data['priceChange'] as num?)?.toDouble() ?? 0.0;
  double get priceChangePercent =>
      (data['priceChangePercent'] as num?)?.toDouble() ?? 0.0;
  double get volume => (data['volume'] as num?)?.toDouble() ?? 0.0;
  double get highPrice => (data['highPrice'] as num?)?.toDouble() ?? 0.0;
  double get lowPrice => (data['lowPrice'] as num?)?.toDouble() ?? 0.0;
}

/// Order book depth message
class OrderBookMessage extends WebSocketMessage {
  OrderBookMessage({
    required String symbol,
    required int timestamp,
    required Map<String, dynamic> data,
  }) : super(type: 'depth', symbol: symbol, timestamp: timestamp, data: data);

  factory OrderBookMessage.fromJson(Map<String, dynamic> json) {
    return OrderBookMessage(
      symbol: json['symbol'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      data: json['data'] ?? {},
    );
  }

  List<List<double>> get bids {
    final List<dynamic> bidsList = data['bids'] ?? [];
    return bidsList
        .map(
          (bid) => (bid as List<dynamic>)
              .map((value) => (value as num).toDouble())
              .toList(),
        )
        .toList();
  }

  List<List<double>> get asks {
    final List<dynamic> asksList = data['asks'] ?? [];
    return asksList
        .map(
          (ask) => (ask as List<dynamic>)
              .map((value) => (value as num).toDouble())
              .toList(),
        )
        .toList();
  }
}

/// Trade data message
class TradeMessage extends WebSocketMessage {
  TradeMessage({
    required String symbol,
    required int timestamp,
    required Map<String, dynamic> data,
  }) : super(type: 'trade', symbol: symbol, timestamp: timestamp, data: data);

  factory TradeMessage.fromJson(Map<String, dynamic> json) {
    return TradeMessage(
      symbol: json['symbol'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      data: json['data'] ?? {},
    );
  }

  String get id => data['id'] ?? '';
  double get price => (data['price'] as num?)?.toDouble() ?? 0.0;
  double get quantity => (data['quantity'] as num?)?.toDouble() ?? 0.0;
  bool get isBuyerMaker => data['isBuyerMaker'] ?? false;
  int get time => data['time'] ?? DateTime.now().millisecondsSinceEpoch;
}

/// Kline/candlestick data message
class KlineMessage extends WebSocketMessage {
  KlineMessage({
    required String symbol,
    required int timestamp,
    required Map<String, dynamic> data,
  }) : super(type: 'kline', symbol: symbol, timestamp: timestamp, data: data);

  factory KlineMessage.fromJson(Map<String, dynamic> json) {
    return KlineMessage(
      symbol: json['symbol'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      data: json['data'] ?? {},
    );
  }

  String get interval => data['interval'] ?? '1m';
  int get openTime => data['openTime'] ?? 0;
  int get closeTime => data['closeTime'] ?? 0;
  double get open => (data['openPrice'] as num?)?.toDouble() ?? 0.0;
  double get high => (data['highPrice'] as num?)?.toDouble() ?? 0.0;
  double get low => (data['lowPrice'] as num?)?.toDouble() ?? 0.0;
  double get close => (data['closePrice'] as num?)?.toDouble() ?? 0.0;
  double get volume => (data['volume'] as num?)?.toDouble() ?? 0.0;
  int get tradeCount => data['tradeCount'] ?? 0;
}

/// Order update message for user data channel
class OrderUpdateMessage extends WebSocketMessage {
  OrderUpdateMessage({
    required int timestamp,
    required Map<String, dynamic> data,
  }) : super(type: 'userData', timestamp: timestamp, data: data);

  factory OrderUpdateMessage.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> dataObj = json['data'] ?? {};
    final Map<String, dynamic> orderData = dataObj['data'] ?? {};

    return OrderUpdateMessage(
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      data: {
        'eventType': dataObj['eventType'] ?? 'ORDER_UPDATE',
        'eventTime':
            dataObj['eventTime'] ?? DateTime.now().millisecondsSinceEpoch,
        'data': orderData,
      },
    );
  }

  Map<String, dynamic> get orderData =>
      (data['data'] as Map<String, dynamic>?) ?? {};
  String get eventType => data['eventType'] ?? 'ORDER_UPDATE';
  int get eventTime =>
      data['eventTime'] ?? DateTime.now().millisecondsSinceEpoch;

  String get id => orderData['id'] ?? '';
  String get clientOrderId => orderData['clientOrderId'] ?? '';
  String get symbol => orderData['symbol'] ?? '';
  String get side => orderData['side'] ?? '';
  String get orderType => orderData['orderType'] ?? '';
  String get timeInForce => orderData['timeInForce'] ?? '';
  double get originalQuantity =>
      (orderData['originalQuantity'] as num?)?.toDouble() ?? 0.0;
  double get executedQuantity =>
      (orderData['executedQuantity'] as num?)?.toDouble() ?? 0.0;
  double get cumulativeQuoteQuantity =>
      (orderData['cumulativeQuoteQuantity'] as num?)?.toDouble() ?? 0.0;
  String get status => orderData['status'] ?? '';
  double get price => (orderData['price'] as num?)?.toDouble() ?? 0.0;
  double? get stopPrice => (orderData['stopPrice'] as num?)?.toDouble();
  double? get icebergQuantity =>
      (orderData['icebergQuantity'] as num?)?.toDouble();
  int get updateTime =>
      orderData['updateTime'] ?? DateTime.now().millisecondsSinceEpoch;
}

/// Balance update message for user data channel
class BalanceUpdateMessage extends WebSocketMessage {
  BalanceUpdateMessage({
    required int timestamp,
    required Map<String, dynamic> data,
  }) : super(type: 'userData', timestamp: timestamp, data: data);

  factory BalanceUpdateMessage.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> dataObj = json['data'] ?? {};
    final Map<String, dynamic> balanceData = dataObj['data'] ?? {};

    return BalanceUpdateMessage(
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      data: {
        'eventType': dataObj['eventType'] ?? 'BALANCE_UPDATE',
        'eventTime':
            dataObj['eventTime'] ?? DateTime.now().millisecondsSinceEpoch,
        'data': balanceData,
      },
    );
  }

  Map<String, dynamic> get balanceData =>
      (data['data'] as Map<String, dynamic>?) ?? {};
  String get eventType => data['eventType'] ?? 'BALANCE_UPDATE';
  int get eventTime =>
      data['eventTime'] ?? DateTime.now().millisecondsSinceEpoch;

  String get asset => balanceData['asset'] ?? '';
  double get free => (balanceData['free'] as num?)?.toDouble() ?? 0.0;
  double get locked => (balanceData['locked'] as num?)?.toDouble() ?? 0.0;
  double get total => free + locked;
  int get updateTime =>
      balanceData['updateTime'] ?? DateTime.now().millisecondsSinceEpoch;
}

/// Subscription request message
class SubscriptionRequest {
  final String type;
  final List<String> channels;
  final List<String> symbols;

  SubscriptionRequest({
    this.type = 'SUBSCRIBE',
    required this.channels,
    this.symbols = const [],
  });

  Map<String, dynamic> toJson() {
    return {'type': type, 'channels': channels, 'symbols': symbols};
  }
}

/// Unsubscription request message
class UnsubscriptionRequest {
  final String type;
  final List<String> channels;
  final List<String> symbols;

  UnsubscriptionRequest({
    this.type = 'UNSUBSCRIBE',
    required this.channels,
    this.symbols = const [],
  });

  Map<String, dynamic> toJson() {
    return {'type': type, 'channels': channels, 'symbols': symbols};
  }
}

/// Ping message
class PingMessage {
  final String type;

  PingMessage() : type = 'PING';

  Map<String, dynamic> toJson() {
    return {'type': type};
  }
}

/// Pong message response
class PongMessage extends WebSocketMessage {
  PongMessage({required int timestamp})
    : super(type: 'PONG', timestamp: timestamp, data: null);

  factory PongMessage.fromJson(Map<String, dynamic> json) {
    return PongMessage(
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
