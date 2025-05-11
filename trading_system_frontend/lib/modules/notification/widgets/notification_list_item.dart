import 'package:flutter/material.dart';
import '../../../services/models/notification_models.dart' as models;

class NotificationListItem extends StatelessWidget {
  final models.Notification notification;
  final VoidCallback onMarkAsRead;

  const NotificationListItem({
    Key? key,
    required this.notification,
    required this.onMarkAsRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? bgColor;
    IconData iconData;
    Color iconColor;

    // Styling based on notification type
    switch (notification.type) {
      case 'ORDER':
        iconData = Icons.receipt;
        iconColor = Colors.amber;
        break;
      case 'TRADE':
        iconData = Icons.swap_horiz;
        iconColor = Colors.green;
        break;
      case 'ACCOUNT':
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.blue;
        break;
      case 'RISK':
        iconData = Icons.warning;
        iconColor = Colors.red;
        break;
      case 'SYSTEM':
        iconData = Icons.notifications;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = theme.colorScheme.primary;
    }

    // Unread notifications have a light background color
    if (!notification.isRead) {
      bgColor = theme.colorScheme.surfaceVariant.withOpacity(0.3);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: bgColor,
      child: InkWell(
        onTap: onMarkAsRead,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left icon
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(iconData, color: iconColor),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Indicator for unread notifications
                        if (!notification.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Message
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),

                    // Timestamp
                    Text(
                      _formatDate(notification.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
