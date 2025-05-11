import 'package:flutter/material.dart';

/// Shows a custom snackbar with the given message
void showCustomSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
  bool isSuccess = false,
  Duration duration = const Duration(seconds: 3),
}) {
  final theme = Theme.of(context);

  Color backgroundColor;
  IconData iconData;

  if (isError) {
    backgroundColor = theme.colorScheme.error;
    iconData = Icons.error_outline;
  } else if (isSuccess) {
    backgroundColor = Colors.green;
    iconData = Icons.check_circle_outline;
  } else {
    backgroundColor = theme.colorScheme.primary;
    iconData = Icons.info_outline;
  }

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(iconData, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'DISMISS',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}

/// Shows an error snackbar with the given message
void showErrorSnackBar(BuildContext context, String message) {
  showCustomSnackBar(context, message: message, isError: true);
}

/// Shows a success snackbar with the given message
void showSuccessSnackBar(BuildContext context, String message) {
  showCustomSnackBar(context, message: message, isSuccess: true);
}

/// Shows an info snackbar with the given message
void showInfoSnackBar(BuildContext context, String message) {
  showCustomSnackBar(context, message: message);
}
