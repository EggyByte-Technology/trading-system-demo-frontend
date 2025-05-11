// Trading models based on backend CommonLib.Models.Trading

/// Order model
class Order {
  final String id;
  final String userId;
  final String symbol;
  final String side;
  final String type;
  final String status;
  final String timeInForce;
  final double price;
  final double originalQuantity;
  final double executedQuantity;
  final double? stopPrice;
  final double? icebergQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isWorking;
  final List<String> tradeIds;
  final List<Trade>? trades;

  Order({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.side,
    required this.type,
    required this.status,
    required this.timeInForce,
    required this.price,
    required this.originalQuantity,
    required this.executedQuantity,
    this.stopPrice,
    this.icebergQuantity,
    required this.createdAt,
    required this.updatedAt,
    required this.isWorking,
    required this.tradeIds,
    this.trades,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      symbol: json['symbol'] ?? '',
      side: json['side'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'NEW',
      timeInForce: json['timeInForce'] ?? 'GTC',
      price: (json['price'] ?? 0.0).toDouble(),
      originalQuantity: (json['originalQuantity'] ?? json['origQty'] ?? 0.0)
          .toDouble(),
      executedQuantity: (json['executedQuantity'] ?? json['executedQty'] ?? 0.0)
          .toDouble(),
      stopPrice: json['stopPrice'] != null
          ? (json['stopPrice']).toDouble()
          : null,
      icebergQuantity: json['icebergQuantity'] != null
          ? (json['icebergQuantity']).toDouble()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : DateTime.now(),
      isWorking: json['isWorking'] ?? true,
      tradeIds: json['tradeIds'] != null
          ? List<String>.from(json['tradeIds'])
          : [],
      trades: json['trades'] != null
          ? List<Trade>.from(json['trades'].map((x) => Trade.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'symbol': symbol,
      'side': side,
      'type': type,
      'status': status,
      'timeInForce': timeInForce,
      'price': price,
      'originalQuantity': originalQuantity,
      'executedQuantity': executedQuantity,
      if (stopPrice != null) 'stopPrice': stopPrice,
      if (icebergQuantity != null) 'icebergQuantity': icebergQuantity,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isWorking': isWorking,
      'tradeIds': tradeIds,
      if (trades != null) 'trades': trades!.map((x) => x.toJson()).toList(),
    };
  }
}

/// Trade model
class Trade {
  final String id;
  final String symbol;
  final String orderId;
  final String buyerOrderId;
  final String sellerOrderId;
  final String buyerUserId;
  final String sellerUserId;
  final double price;
  final double quantity;
  final double buyerFee;
  final double sellerFee;
  final String buyerFeeAsset;
  final String sellerFeeAsset;
  final DateTime createdAt;
  final bool isBuyerMaker;

  Trade({
    required this.id,
    required this.symbol,
    required this.orderId,
    required this.buyerOrderId,
    required this.sellerOrderId,
    required this.buyerUserId,
    required this.sellerUserId,
    required this.price,
    required this.quantity,
    required this.buyerFee,
    required this.sellerFee,
    required this.buyerFeeAsset,
    required this.sellerFeeAsset,
    required this.createdAt,
    required this.isBuyerMaker,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['_id'] ?? json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      orderId: json['orderId'] ?? '',
      buyerOrderId: json['buyerOrderId'] ?? '',
      sellerOrderId: json['sellerOrderId'] ?? '',
      buyerUserId: json['buyerUserId'] ?? '',
      sellerUserId: json['sellerUserId'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: (json['quantity'] ?? json['qty'] ?? 0.0).toDouble(),
      buyerFee: (json['buyerFee'] ?? 0.0).toDouble(),
      sellerFee: (json['sellerFee'] ?? 0.0).toDouble(),
      buyerFeeAsset: json['buyerFeeAsset'] ?? '',
      sellerFeeAsset: json['sellerFeeAsset'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      isBuyerMaker: json['isBuyerMaker'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'orderId': orderId,
      'buyerOrderId': buyerOrderId,
      'sellerOrderId': sellerOrderId,
      'buyerUserId': buyerUserId,
      'sellerUserId': sellerUserId,
      'price': price,
      'quantity': quantity,
      'buyerFee': buyerFee,
      'sellerFee': sellerFee,
      'buyerFeeAsset': buyerFeeAsset,
      'sellerFeeAsset': sellerFeeAsset,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isBuyerMaker': isBuyerMaker,
    };
  }
}

/// Order request model
class OrderRequest {
  final String symbol;
  final String side;
  final String type;
  final String? timeInForce;
  final double quantity;
  final double? price;
  final double? stopPrice;
  final double? icebergQuantity;

  OrderRequest({
    required this.symbol,
    required this.side,
    required this.type,
    this.timeInForce,
    required this.quantity,
    this.price,
    this.stopPrice,
    this.icebergQuantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'side': side,
      'type': type,
      if (timeInForce != null) 'timeInForce': timeInForce,
      'quantity': quantity,
      if (price != null) 'price': price,
      if (stopPrice != null) 'stopPrice': stopPrice,
      if (icebergQuantity != null) 'icebergQuantity': icebergQuantity,
    };
  }
}
