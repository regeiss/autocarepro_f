import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Log levels for the AppLogger
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// A comprehensive logging service for the AutoCarePro app
/// 
/// Usage:
/// ```dart
/// AppLogger.debug('Debug message');
/// AppLogger.info('Info message');
/// AppLogger.warning('Warning message');
/// AppLogger.error('Error occurred', error: e, stackTrace: stackTrace);
/// AppLogger.critical('Critical error', error: e);
/// ```
class AppLogger {
  static const String _name = 'AutoCarePro';
  static LogLevel _minimumLogLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Set the minimum log level to display
  static void setMinimumLogLevel(LogLevel level) {
    _minimumLogLevel = level;
  }

  /// Log a debug message
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      level: LogLevel.debug,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Log an info message
  static void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      level: LogLevel.info,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Log a warning message
  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      level: LogLevel.warning,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Log an error message
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      level: LogLevel.error,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Log a critical error message
  static void critical(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      level: LogLevel.critical,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Internal logging method
  static void _log({
    required LogLevel level,
    required String message,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    // Check if we should log based on minimum level
    if (level.index < _minimumLogLevel.index) {
      return;
    }

    // Format the log message
    final buffer = StringBuffer();
    
    // Add tag if provided
    if (tag != null) {
      buffer.write('[$tag] ');
    }
    
    // Add the main message
    buffer.write(message);

    // Add additional data if provided
    if (data != null && data.isNotEmpty) {
      buffer.write('\nData: ${data.toString()}');
    }

    // Add error if provided
    if (error != null) {
      buffer.write('\nError: $error');
    }

    // Add stack trace if provided
    if (stackTrace != null) {
      buffer.write('\nStackTrace: $stackTrace');
    }

    final logMessage = buffer.toString();

    // Use developer.log for better debugging in IDEs
    developer.log(
      logMessage,
      time: DateTime.now(),
      name: _name,
      level: _getLevelValue(level),
      error: error,
      stackTrace: stackTrace,
    );

    // Also print to console for easier viewing during development
    if (kDebugMode) {
      final emoji = _getLevelEmoji(level);
      final levelName = level.name.toUpperCase().padRight(8);
      final timestamp = DateTime.now().toIso8601String();
      
      // Print with color coding via level indicator
      print('$emoji [$levelName] $timestamp - $logMessage');
    }
  }

  /// Get numeric value for log level (for developer.log)
  static int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }

  /// Get emoji for log level
  static String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return '💡';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🔥';
    }
  }
}

/// Extension for easily logging database operations
extension DatabaseLogger on Object {
  void logDatabaseOperation(String operation, {Map<String, dynamic>? data}) {
    AppLogger.debug(
      operation,
      tag: 'Database',
      data: data,
    );
  }
}

/// Extension for easily logging navigation events
extension NavigationLogger on Object {
  void logNavigation(String route, {Map<String, dynamic>? params}) {
    AppLogger.info(
      'Navigating to: $route',
      tag: 'Navigation',
      data: params,
    );
  }
}

/// Extension for easily logging service operations
extension ServiceLogger on Object {
  void logServiceOperation(String service, String operation, {Map<String, dynamic>? data}) {
    AppLogger.info(
      '$service: $operation',
      tag: 'Service',
      data: data,
    );
  }
}
