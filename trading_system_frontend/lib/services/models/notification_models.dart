// Notification models based on backend CommonLib.Models.Notification

/// Notification model
class Notification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] ?? {},
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      readAt: json['readAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['readAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.millisecondsSinceEpoch,
      if (readAt != null) 'readAt': readAt!.millisecondsSinceEpoch,
    };
  }
}

/// Notification settings model
class NotificationSettings {
  final String id;
  final String userId;
  final bool emailNotificationsEnabled;
  final bool pushNotificationsEnabled;
  final Map<String, bool> typeSettings;

  NotificationSettings({
    required this.id,
    required this.userId,
    required this.emailNotificationsEnabled,
    required this.pushNotificationsEnabled,
    required this.typeSettings,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    Map<String, bool> settings = {};
    if (json['typeSettings'] != null) {
      json['typeSettings'].forEach((key, value) {
        settings[key] = value ?? false;
      });
    }

    return NotificationSettings(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      emailNotificationsEnabled: json['emailNotificationsEnabled'] ?? true,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      typeSettings: settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'typeSettings': typeSettings,
    };
  }
}

/// WebSocket connection model
class WebSocketConnection {
  final String id;
  final String userId;
  final String connectionId;
  final DateTime connectedAt;
  final DateTime? disconnectedAt;
  final bool isActive;
  final List<String> subscribedChannels;

  WebSocketConnection({
    required this.id,
    required this.userId,
    required this.connectionId,
    required this.connectedAt,
    this.disconnectedAt,
    required this.isActive,
    required this.subscribedChannels,
  });

  factory WebSocketConnection.fromJson(Map<String, dynamic> json) {
    return WebSocketConnection(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      connectionId: json['connectionId'] ?? '',
      connectedAt: json['connectedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['connectedAt'])
          : DateTime.now(),
      disconnectedAt: json['disconnectedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['disconnectedAt'])
          : null,
      isActive: json['isActive'] ?? true,
      subscribedChannels: json['subscribedChannels'] != null
          ? List<String>.from(json['subscribedChannels'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'connectionId': connectionId,
      'connectedAt': connectedAt.millisecondsSinceEpoch,
      if (disconnectedAt != null)
        'disconnectedAt': disconnectedAt!.millisecondsSinceEpoch,
      'isActive': isActive,
      'subscribedChannels': subscribedChannels,
    };
  }
}

/// WebSocket subscription request
class WebSocketSubscription {
  final String type;
  final List<String> channels;
  final List<String> symbols;

  WebSocketSubscription({
    required this.type,
    required this.channels,
    required this.symbols,
  });

  Map<String, dynamic> toJson() {
    return {'type': type, 'channels': channels, 'symbols': symbols};
  }
}
