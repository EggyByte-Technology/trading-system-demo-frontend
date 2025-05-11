import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/notification_manager.dart';
import '../../../services/models/notification_models.dart' as models;

/// Provider for fetching user notifications
final notificationsProvider = FutureProvider<List<models.Notification>>((
  ref,
) async {
  return NotificationManager.getNotifications();
});

/// Provider for fetching notification settings
final notificationSettingsProvider =
    FutureProvider<models.NotificationSettings>((ref) async {
      return NotificationManager.getNotificationSettings();
    });
