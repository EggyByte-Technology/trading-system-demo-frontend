import '../models/market_models.dart';
import 'api_client.dart';

/// Manager for market data API calls
class MarketManager {
  /// Get all trading symbols
  static Future<List<Symbol>> getSymbols() async {
    final response = await ApiClient.get('market', '/market/symbols');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get symbols');
    }

    final List<dynamic> symbols = response.data['symbols'] ?? [];
    return symbols.map((symbol) => Symbol.fromJson(symbol)).toList();
  }

  /// Get ticker information for a symbol
  ///
  /// [symbol] Symbol name
  static Future<MarketData> getTicker(String symbol) async {
    final response = await ApiClient.get(
      'market',
      '/market/ticker',
      queryParameters: {'symbol': symbol},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get ticker');
    }

    return MarketData.fromJson(response.data);
  }

  /// Get market summary for all symbols
  static Future<List<MarketData>> getMarketSummary() async {
    final response = await ApiClient.get('market', '/market/summary');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get market summary');
    }

    final List<dynamic> markets = response.data['markets'] ?? [];
    return markets.map((market) => MarketData.fromJson(market)).toList();
  }

  /// Get order book depth
  ///
  /// [symbol] Symbol name
  /// [limit] Maximum number of price levels (default: 100, max: 500)
  static Future<OrderBook> getOrderBookDepth(
    String symbol, {
    int limit = 100,
  }) async {
    final response = await ApiClient.get(
      'market',
      '/market/depth',
      queryParameters: {'symbol': symbol, 'limit': limit},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.errorMessage ?? 'Failed to get order book depth',
      );
    }

    return OrderBook.fromJson({'symbol': symbol, ...response.data});
  }

  /// Get kline/candlestick data
  ///
  /// [symbol] Symbol name
  /// [interval] Kline interval (default: 1h)
  /// [startTime] Start time in milliseconds (optional)
  /// [endTime] End time in milliseconds (optional)
  /// [limit] Maximum number of klines (default: 500, max: 1000)
  static Future<List<Kline>> getKlines({
    required String symbol,
    String interval = '1h',
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final queryParams = <String, dynamic>{
      'symbol': symbol,
      'interval': interval,
      'limit': limit,
    };

    if (startTime != null) queryParams['startTime'] = startTime;
    if (endTime != null) queryParams['endTime'] = endTime;

    final response = await ApiClient.get(
      'market',
      '/market/klines',
      queryParameters: queryParams,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get klines');
    }

    final List<dynamic> klines = response.data ?? [];
    return klines.map((kline) {
      return Kline.fromJson({
        'symbol': symbol,
        'interval': interval,
        ...kline is List ? {} : kline as Map<String, dynamic>,
        // For array-based response
        if (kline is List) 'openTime': kline[0],
        if (kline is List) 'open': kline[1],
        if (kline is List) 'high': kline[2],
        if (kline is List) 'low': kline[3],
        if (kline is List) 'close': kline[4],
        if (kline is List) 'volume': kline[5],
        if (kline is List) 'closeTime': kline[6],
        if (kline is List) 'quoteVolume': kline[7],
        if (kline is List) 'trades': kline[8],
      });
    }).toList();
  }

  /// Get recent trades
  ///
  /// [symbol] Symbol name
  /// [limit] Maximum number of trades (default: 100, max: 1000)
  static Future<List<dynamic>> getRecentTrades(
    String symbol, {
    int limit = 100,
  }) async {
    final response = await ApiClient.get(
      'market',
      '/market/trades',
      queryParameters: {'symbol': symbol, 'limit': limit},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get recent trades');
    }

    return response.data;
  }
}
