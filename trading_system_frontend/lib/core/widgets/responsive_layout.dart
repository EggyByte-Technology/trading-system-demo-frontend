import 'package:flutter/material.dart';

/// A widget that constrains its child to a maximum width and centers it
/// Used to create a more desktop/tablet-friendly layout for the application
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 800.0, // Default max width for content
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
