import '../models/trading_models.dart';
import 'api_client.dart';

/// Manager for trading-related API calls
class TradingManager {
  /// Create a new order
  ///
  /// [symbol] Trading pair
  /// [side] Order side (BUY or SELL)
  /// [type] Order type (LIMIT, MARKET, etc.)
  /// [quantity] Order quantity
  /// [price] Order price (required for LIMIT orders)
  /// [timeInForce] Time in force (GTC, IOC, FOK)
  /// [stopPrice] Stop price (for stop orders)
  /// [icebergQty] Iceberg quantity
  static Future<Order> createOrder({
    required String symbol,
    required String side,
    required String type,
    required double quantity,
    double? price,
    String? timeInForce,
    double? stopPrice,
    double? icebergQty,
  }) async {
    final data = <String, dynamic>{
      'symbol': symbol,
      'side': side,
      'type': type,
      'quantity': quantity,
    };

    if (price != null) data['price'] = price;
    if (timeInForce != null) data['timeInForce'] = timeInForce;
    if (stopPrice != null) data['stopPrice'] = stopPrice;
    if (icebergQty != null) data['icebergQty'] = icebergQty;

    final response = await ApiClient.post('trading', '/order', data: data);

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to create order');
    }

    return Order.fromJson(response.data);
  }

  /// Cancel an order
  ///
  /// [orderId] Order ID to cancel
  static Future<void> cancelOrder(String orderId) async {
    final response = await ApiClient.delete('trading', '/order/$orderId');

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to cancel order');
    }
  }

  /// Get order details
  ///
  /// [orderId] Order ID
  static Future<Order> getOrderDetails(String orderId) async {
    final response = await ApiClient.get('trading', '/order/$orderId');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get order details');
    }

    return Order.fromJson(response.data);
  }

  /// Get open orders
  ///
  /// [symbol] Symbol filter (optional)
  static Future<List<Order>> getOpenOrders({String? symbol}) async {
    final queryParams = <String, dynamic>{};
    if (symbol != null) queryParams['symbol'] = symbol;

    final response = await ApiClient.get(
      'trading',
      '/order/open',
      queryParameters: queryParams,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to get open orders');
    }

    final List<dynamic> orders = response.data ?? [];
    return orders.map((order) => Order.fromJson(order)).toList();
  }

  /// Get order history
  ///
  /// [symbol] Symbol filter (optional)
  /// [status] Status filter (optional)
  /// [side] Side filter (optional)
  /// [type] Type filter (optional)
  /// [startTime] Start time in milliseconds (optional)
  /// [endTime] End time in milliseconds (optional)
  /// [page] Page number (default: 1)
  /// [pageSize] Page size (default: 20)
  static Future<({int total, int page, int pageSize, List<Order> items})>
  getOrderHistory({
    String? symbol,
    String? status,
    String? side,
    String? type,
    int? startTime,
    int? endTime,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'pageSize': pageSize};

    if (symbol != null) queryParams['symbol'] = symbol;
    if (status != null) queryParams['status'] = status;
    if (side != null) queryParams['side'] = side;
    if (type != null) queryParams['type'] = type;
    if (startTime != null) queryParams['startTime'] = startTime;
    if (endTime != null) queryParams['endTime'] = endTime;

    final response = await ApiClient.get(
      'trading',
      '/order/history',
      queryParameters: queryParams,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get order history');
    }

    final data = response.data;
    final List<dynamic> items = data['items'] ?? [];

    return (
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      pageSize: data['pageSize'] as int? ?? pageSize,
      items: items.map((item) => Order.fromJson(item)).toList(),
    );
  }

  /// Get trade history
  ///
  /// [symbol] Symbol filter (optional)
  /// [startTime] Start time in seconds (optional)
  /// [endTime] End time in seconds (optional)
  /// [page] Page number (default: 1)
  /// [pageSize] Page size (default: 20, max: 100)
  static Future<({int total, int page, int pageSize, List<Trade> items})>
  getTradeHistory({
    String? symbol,
    int? startTime,
    int? endTime,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'pageSize': pageSize};

    if (symbol != null) queryParams['symbol'] = symbol;
    if (startTime != null) queryParams['startTime'] = startTime;
    if (endTime != null) queryParams['endTime'] = endTime;

    final response = await ApiClient.get(
      'trading',
      '/trade/history',
      queryParameters: queryParams,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get trade history');
    }

    final data = response.data;
    final List<dynamic> items = data['items'] ?? [];

    return (
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      pageSize: data['pageSize'] as int? ?? pageSize,
      items: items.map((item) => Trade.fromJson(item)).toList(),
    );
  }
}
