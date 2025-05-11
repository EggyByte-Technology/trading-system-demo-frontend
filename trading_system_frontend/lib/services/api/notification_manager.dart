import '../models/notification_models.dart';
import 'api_client.dart';

/// Manager for notification-related API calls
class NotificationManager {
  /// Get user notifications
  static Future<List<Notification>> getNotifications() async {
    final response = await ApiClient.get('notification', '/notification');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get notifications');
    }

    final List<dynamic> notifications = response.data;
    return notifications.map((notif) => Notification.fromJson(notif)).toList();
  }

  /// Mark notification as read
  ///
  /// [id] Notification ID to mark as read
  static Future<Notification> markNotificationAsRead(String id) async {
    final response = await ApiClient.put(
      'notification',
      '/notification/$id/read',
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.errorMessage ?? 'Failed to mark notification as read',
      );
    }

    return Notification.fromJson(response.data);
  }

  /// Get notification settings
  static Future<NotificationSettings> getNotificationSettings() async {
    final response = await ApiClient.get(
      'notification',
      '/notification/settings',
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.errorMessage ?? 'Failed to get notification settings',
      );
    }

    return NotificationSettings.fromJson(response.data);
  }

  /// Update notification settings
  ///
  /// [emailNotificationsEnabled] Enable email notifications
  /// [pushNotificationsEnabled] Enable push notifications
  /// [typeSettings] Settings for different notification types
  static Future<NotificationSettings> updateNotificationSettings({
    required bool emailNotificationsEnabled,
    required bool pushNotificationsEnabled,
    required Map<String, bool> typeSettings,
  }) async {
    final data = {
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'typeSettings': typeSettings,
    };

    final response = await ApiClient.post(
      'notification',
      '/notification/settings',
      data: data,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.errorMessage ?? 'Failed to update notification settings',
      );
    }

    return NotificationSettings.fromJson(response.data);
  }
}
