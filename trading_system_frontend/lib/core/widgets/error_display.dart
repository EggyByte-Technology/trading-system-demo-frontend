import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A reusable widget for displaying error messages in a consistent style
class ErrorDisplay extends StatelessWidget {
  /// The error message to display
  final String message;

  /// Optional padding to apply around the error display
  final EdgeInsetsGeometry? padding;

  /// Optional margin to apply around the error display
  final EdgeInsetsGeometry? margin;

  /// Whether to show an icon with the error message
  final bool showIcon;

  /// Create a new error display widget
  const ErrorDisplay({
    super.key,
    required this.message,
    this.padding,
    this.margin,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16.0),
      padding: padding ?? const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: AppTheme.negativeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.negativeColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            const Icon(
              Icons.error_outline,
              color: AppTheme.negativeColor,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.negativeColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
