// Risk models based on backend CommonLib.Models.Risk

/// Risk alert model
class RiskAlert {
  final String id;
  final String userId;
  final String type;
  final String message;
  final String severity;
  final DateTime createdAt;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;

  RiskAlert({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.severity,
    required this.createdAt,
    required this.isAcknowledged,
    this.acknowledgedAt,
  });

  factory RiskAlert.fromJson(Map<String, dynamic> json) {
    return RiskAlert(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'INFO',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      isAcknowledged: json['isAcknowledged'] ?? json['acknowledged'] ?? false,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['acknowledgedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'message': message,
      'severity': severity,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isAcknowledged': isAcknowledged,
      if (acknowledgedAt != null)
        'acknowledgedAt': acknowledgedAt!.millisecondsSinceEpoch,
    };
  }
}

/// Trading limits model
class TradingLimits {
  final double dailyWithdrawalLimit;
  final double singleOrderLimit;
  final double dailyTradingLimit;
  final Map<String, double> assetSpecificLimits;

  TradingLimits({
    required this.dailyWithdrawalLimit,
    required this.singleOrderLimit,
    required this.dailyTradingLimit,
    required this.assetSpecificLimits,
  });

  factory TradingLimits.fromJson(Map<String, dynamic> json) {
    Map<String, double> assetLimits = {};
    if (json['assetSpecificLimits'] != null) {
      json['assetSpecificLimits'].forEach((key, value) {
        assetLimits[key] = (value ?? 0.0).toDouble();
      });
    }

    return TradingLimits(
      dailyWithdrawalLimit:
          (json['dailyWithdrawalLimit'] ?? json['maxDailyWithdrawal'] ?? 0.0)
              .toDouble(),
      singleOrderLimit:
          (json['singleOrderLimit'] ?? json['maxSingleOrder'] ?? 0.0)
              .toDouble(),
      dailyTradingLimit:
          (json['dailyTradingLimit'] ?? json['maxDailyTrading'] ?? 0.0)
              .toDouble(),
      assetSpecificLimits: assetLimits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyWithdrawalLimit': dailyWithdrawalLimit,
      'singleOrderLimit': singleOrderLimit,
      'dailyTradingLimit': dailyTradingLimit,
      'assetSpecificLimits': assetSpecificLimits,
    };
  }
}

/// Risk profile model
class RiskProfile {
  final String id;
  final String userId;
  final String riskLevel;
  final TradingLimits limits;
  final DateTime createdAt;
  final DateTime updatedAt;

  RiskProfile({
    required this.id,
    required this.userId,
    required this.riskLevel,
    required this.limits,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RiskProfile.fromJson(Map<String, dynamic> json) {
    return RiskProfile(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      riskLevel: json['riskLevel'] ?? 'LOW',
      limits: json['limits'] != null
          ? TradingLimits.fromJson(json['limits'])
          : TradingLimits(
              dailyWithdrawalLimit: 0.0,
              singleOrderLimit: 0.0,
              dailyTradingLimit: 0.0,
              assetSpecificLimits: {},
            ),
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'riskLevel': riskLevel,
      'limits': limits.toJson(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}

/// Risk rule model
class RiskRule {
  final String id;
  final String name;
  final String description;
  final String condition;
  final String action;
  final String severity;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RiskRule({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    required this.action,
    required this.severity,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RiskRule.fromJson(Map<String, dynamic> json) {
    return RiskRule(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      condition: json['condition'] ?? '',
      action: json['action'] ?? '',
      severity: json['severity'] ?? 'INFO',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'condition': condition,
      'action': action,
      'severity': severity,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}
