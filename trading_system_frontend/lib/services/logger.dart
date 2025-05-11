import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum LogLevel { debug, info, warning, error, severe }

class Logger {
  // ANSI color codes for console output
  static const String _resetColor = '\x1B[0m';
  static const String _debugColor = '\x1B[36m'; // Cyan
  static const String _infoColor = '\x1B[32m'; // Green
  static const String _warningColor = '\x1B[33m'; // Yellow
  static const String _errorColor = '\x1B[31m'; // Red
  static const String _severeColor = '\x1B[35m'; // Magenta

  // Date formatter for timestamps
  static final DateFormat _dateFormatter = DateFormat(
    'yyyy-MM-dd HH:mm:ss.SSS',
  );

  static String _getColorForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return _debugColor;
      case LogLevel.info:
        return _infoColor;
      case LogLevel.warning:
        return _warningColor;
      case LogLevel.error:
        return _errorColor;
      case LogLevel.severe:
        return _severeColor;
    }
  }

  static String _getLevelName(LogLevel level) {
    return level.toString().split('.').last.toUpperCase();
  }

  /// Log a message with a specific log level
  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return; // Only log in debug mode

    final timestamp = _dateFormatter.format(DateTime.now());
    final levelName = _getLevelName(level);
    final color = _getColorForLevel(level);

    // Format: [TIMESTAMP] [LEVEL] MESSAGE
    final formattedMessage =
        '[$timestamp] $color[$levelName] $message$_resetColor';

    debugPrint(formattedMessage);

    // If there's an error, log it with stack trace
    if (error != null) {
      debugPrint('$color[ERROR] $error$_resetColor');
      if (stackTrace != null) {
        debugPrint('$color[STACK] $stackTrace$_resetColor');
      }
    }
  }

  /// Log a debug message (for detailed debugging information)
  static void d(String message, {Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.debug, error: error, stackTrace: stackTrace);
  }

  /// Log an info message (general information about app execution)
  static void i(String message, {Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.info, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message (potential issues that aren't errors)
  static void w(String message, {Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.warning, error: error, stackTrace: stackTrace);
  }

  /// Log an error message (errors that don't crash the app)
  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);
  }

  /// Log a severe message (critical errors)
  static void s(String message, {Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.severe, error: error, stackTrace: stackTrace);
  }
}
