// Account models based on backend CommonLib.Models.Account

/// Account model with balances
class Account {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final List<Balance> balances;

  Account({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.balances,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : DateTime.now(),
      status: json['status'] ?? 'active',
      balances: json['balances'] != null
          ? List<Balance>.from(json['balances'].map((x) => Balance.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'status': status,
      'balances': balances.map((x) => x.toJson()).toList(),
    };
  }
}

/// Balance model for an asset
class Balance {
  final String asset;
  final double free;
  final double locked;
  final DateTime updatedAt;

  Balance({
    required this.asset,
    required this.free,
    required this.locked,
    required this.updatedAt,
  });

  double get total => free + locked;

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      asset: json['asset'] ?? '',
      free: (json['free'] ?? 0.0).toDouble(),
      locked: (json['locked'] ?? 0.0).toDouble(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'free': free,
      'locked': locked,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}

/// Transaction model for account movements
class Transaction {
  final String id;
  final String userId;
  final String asset;
  final double amount;
  final String type;
  final String status;
  final int timestamp;
  final String? reference;

  Transaction({
    required this.id,
    required this.userId,
    required this.asset,
    required this.amount,
    required this.type,
    required this.status,
    required this.timestamp,
    this.reference,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      asset: json['asset'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'asset': asset,
      'amount': amount,
      'type': type,
      'status': status,
      'timestamp': timestamp,
      if (reference != null) 'reference': reference,
    };
  }
}

/// Withdrawal request model
class WithdrawalRequest {
  final String id;
  final String userId;
  final String asset;
  final double amount;
  final String address;
  final String? memo;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  WithdrawalRequest({
    required this.id,
    required this.userId,
    required this.asset,
    required this.amount,
    required this.address,
    this.memo,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      asset: json['asset'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      memo: json['memo'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'asset': asset,
      'amount': amount,
      'address': address,
      if (memo != null) 'memo': memo,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      if (completedAt != null)
        'completedAt': completedAt!.millisecondsSinceEpoch,
    };
  }
}
