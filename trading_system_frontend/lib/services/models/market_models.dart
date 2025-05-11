// Market models based on backend CommonLib.Models.Market

/// Symbol (trading pair) model
class Symbol {
  final String id;
  final String name;
  final String baseAsset;
  final String quoteAsset;
  final int baseAssetPrecision;
  final int quotePrecision;
  final bool isActive;
  final double minOrderSize;
  final double maxOrderSize;
  final double minPrice;
  final double maxPrice;
  final double takerFee;
  final double makerFee;

  Symbol({
    required this.id,
    required this.name,
    required this.baseAsset,
    required this.quoteAsset,
    required this.baseAssetPrecision,
    required this.quotePrecision,
    required this.isActive,
    required this.minOrderSize,
    required this.maxOrderSize,
    required this.minPrice,
    required this.maxPrice,
    required this.takerFee,
    required this.makerFee,
  });

  factory Symbol.fromJson(Map<String, dynamic> json) {
    return Symbol(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['symbol'] ?? '',
      baseAsset: json['baseAsset'] ?? '',
      quoteAsset: json['quoteAsset'] ?? '',
      baseAssetPrecision: json['baseAssetPrecision'] ?? 8,
      quotePrecision:
          json['quotePrecision'] ?? json['quoteAssetPrecision'] ?? 2,
      isActive: json['isActive'] ?? json['status'] == 'TRADING',
      minOrderSize: (json['minOrderSize'] ?? json['minQty'] ?? 0.0).toDouble(),
      maxOrderSize: (json['maxOrderSize'] ?? json['maxQty'] ?? 0.0).toDouble(),
      minPrice: (json['minPrice'] ?? 0.0).toDouble(),
      maxPrice: (json['maxPrice'] ?? 0.0).toDouble(),
      takerFee: (json['takerFee'] ?? 0.001).toDouble(),
      makerFee: (json['makerFee'] ?? 0.001).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'baseAsset': baseAsset,
      'quoteAsset': quoteAsset,
      'baseAssetPrecision': baseAssetPrecision,
      'quotePrecision': quotePrecision,
      'isActive': isActive,
      'minOrderSize': minOrderSize,
      'maxOrderSize': maxOrderSize,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'takerFee': takerFee,
      'makerFee': makerFee,
    };
  }
}

/// Market data model
class MarketData {
  final String id;
  final String symbol;
  final double lastPrice;
  final double priceChange;
  final double priceChangePercent;
  final double high24h;
  final double low24h;
  final double volume24h;
  final double quoteVolume24h;
  final DateTime updatedAt;

  MarketData({
    required this.id,
    required this.symbol,
    required this.lastPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    required this.quoteVolume24h,
    required this.updatedAt,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      id: json['_id'] ?? json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      lastPrice: (json['lastPrice'] ?? 0.0).toDouble(),
      priceChange: (json['priceChange'] ?? 0.0).toDouble(),
      priceChangePercent: (json['priceChangePercent'] ?? 0.0).toDouble(),
      high24h: (json['high24h'] ?? json['highPrice'] ?? 0.0).toDouble(),
      low24h: (json['low24h'] ?? json['lowPrice'] ?? 0.0).toDouble(),
      volume24h: (json['volume24h'] ?? json['volume'] ?? 0.0).toDouble(),
      quoteVolume24h: (json['quoteVolume24h'] ?? json['quoteVolume'] ?? 0.0)
          .toDouble(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'lastPrice': lastPrice,
      'priceChange': priceChange,
      'priceChangePercent': priceChangePercent,
      'high24h': high24h,
      'low24h': low24h,
      'volume24h': volume24h,
      'quoteVolume24h': quoteVolume24h,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}

/// Kline (candlestick) model
class Kline {
  final String id;
  final String symbol;
  final String interval;
  final int openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final double quoteVolume;
  final int trades;
  final int closeTime;

  Kline({
    required this.id,
    required this.symbol,
    required this.interval,
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.quoteVolume,
    required this.trades,
    required this.closeTime,
  });

  factory Kline.fromJson(Map<String, dynamic> json) {
    // Handle array format from API
    if (json is List) {
      return Kline(
        id: '',
        symbol: '',
        interval: '',
        openTime: json[0],
        open: (json[1] ?? 0.0).toDouble(),
        high: (json[2] ?? 0.0).toDouble(),
        low: (json[3] ?? 0.0).toDouble(),
        close: (json[4] ?? 0.0).toDouble(),
        volume: (json[5] ?? 0.0).toDouble(),
        closeTime: json[6] ?? 0,
        quoteVolume: (json[7] ?? 0.0).toDouble(),
        trades: json[8] ?? 0,
      );
    }

    return Kline(
      id: json['_id'] ?? json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      interval: json['interval'] ?? '1h',
      openTime: json['openTime'] ?? 0,
      open: (json['open'] ?? 0.0).toDouble(),
      high: (json['high'] ?? 0.0).toDouble(),
      low: (json['low'] ?? 0.0).toDouble(),
      close: (json['close'] ?? 0.0).toDouble(),
      volume: (json['volume'] ?? 0.0).toDouble(),
      quoteVolume: (json['quoteVolume'] ?? 0.0).toDouble(),
      trades: json['trades'] ?? 0,
      closeTime: json['closeTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'interval': interval,
      'openTime': openTime,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'quoteVolume': quoteVolume,
      'trades': trades,
      'closeTime': closeTime,
    };
  }
}

/// Order book depth model
class OrderBook {
  final String symbol;
  final List<List<dynamic>> bids;
  final List<List<dynamic>> asks;
  final int lastUpdateId;

  OrderBook({
    required this.symbol,
    required this.bids,
    required this.asks,
    required this.lastUpdateId,
  });

  factory OrderBook.fromJson(Map<String, dynamic> json) {
    return OrderBook(
      symbol: json['symbol'] ?? '',
      bids: json['bids'] != null
          ? List<List<dynamic>>.from(
              json['bids'].map(
                (x) => [
                  double.parse(x[0].toString()),
                  double.parse(x[1].toString()),
                ],
              ),
            )
          : [],
      asks: json['asks'] != null
          ? List<List<dynamic>>.from(
              json['asks'].map(
                (x) => [
                  double.parse(x[0].toString()),
                  double.parse(x[1].toString()),
                ],
              ),
            )
          : [],
      lastUpdateId: json['lastUpdateId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'bids': bids,
      'asks': asks,
      'lastUpdateId': lastUpdateId,
    };
  }
}
