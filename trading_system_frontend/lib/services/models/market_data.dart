class MarketData {
  final String symbol;
  final double lastPrice;
  final double priceChangePercent;
  final double high24h;
  final double low24h;
  final double volume24h;
  final double quoteVolume24h;
  final bool isFavorite;

  MarketData({
    required this.symbol,
    required this.lastPrice,
    required this.priceChangePercent,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    required this.quoteVolume24h,
    this.isFavorite = false,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      symbol: json['symbol'] as String,
      lastPrice: (json['lastPrice'] as num).toDouble(),
      priceChangePercent: (json['priceChangePercent'] as num).toDouble(),
      high24h: (json['high24h'] as num).toDouble(),
      low24h: (json['low24h'] as num).toDouble(),
      volume24h: (json['volume24h'] as num).toDouble(),
      quoteVolume24h: (json['quoteVolume24h'] as num).toDouble(),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'lastPrice': lastPrice,
      'priceChangePercent': priceChangePercent,
      'high24h': high24h,
      'low24h': low24h,
      'volume24h': volume24h,
      'quoteVolume24h': quoteVolume24h,
      'isFavorite': isFavorite,
    };
  }

  MarketData copyWith({
    String? symbol,
    double? lastPrice,
    double? priceChangePercent,
    double? high24h,
    double? low24h,
    double? volume24h,
    double? quoteVolume24h,
    bool? isFavorite,
  }) {
    return MarketData(
      symbol: symbol ?? this.symbol,
      lastPrice: lastPrice ?? this.lastPrice,
      priceChangePercent: priceChangePercent ?? this.priceChangePercent,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      volume24h: volume24h ?? this.volume24h,
      quoteVolume24h: quoteVolume24h ?? this.quoteVolume24h,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class MarketSummary {
  final int totalTradingPairs;
  final int totalMarkets;
  final double totalVolume24h;
  final List<MarketData> topGainers;
  final List<MarketData> topLosers;

  MarketSummary({
    required this.totalTradingPairs,
    required this.totalMarkets,
    required this.totalVolume24h,
    required this.topGainers,
    required this.topLosers,
  });

  factory MarketSummary.fromJson(Map<String, dynamic> json) {
    return MarketSummary(
      totalTradingPairs: json['totalTradingPairs'] as int,
      totalMarkets: json['totalMarkets'] as int,
      totalVolume24h: (json['totalVolume24h'] as num).toDouble(),
      topGainers: (json['topGainers'] as List)
          .map((e) => MarketData.fromJson(e as Map<String, dynamic>))
          .toList(),
      topLosers: (json['topLosers'] as List)
          .map((e) => MarketData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
