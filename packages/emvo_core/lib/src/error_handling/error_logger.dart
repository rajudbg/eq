import 'dart:developer' as developer;

import 'package:flutter/material.dart';

enum LogLevel { debug, info, warning, error, fatal }

class ErrorLogger {
  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final timestamp = DateTime.now().toIso8601String();

    // In production, send to Sentry/DataDog/etc
    // For now, log to console
    developer.log(
      '[$timestamp] ${level.name.toUpperCase()}: $message',
      name: 'Emvo',
      error: error,
      stackTrace: stackTrace,
    );

    if (level == LogLevel.error || level == LogLevel.fatal) {
      _reportError(message, error, stackTrace, context);
    }
  }

  static void debug(String message) => log(message, level: LogLevel.debug);
  static void info(String message) => log(message, level: LogLevel.info);
  static void warning(String message, {Object? error}) =>
      log(message, level: LogLevel.warning, error: error);
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        message,
        level: LogLevel.error,
        error: error,
        stackTrace: stackTrace,
      );

  static void _reportError(
    String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ) {
    // TODO: Integrate with crash reporting service
    // Sentry.captureException(error, stackTrace: stackTrace, hint: context);
  }
}

/// Installs a global [FlutterError.onError] hook to log and forward errors.
///
/// Do **not** swap out the entire app UI from this callback: [FlutterError.onError]
/// runs for many framework events (e.g. debug layout overflow reporting). Replacing
/// [MaterialApp] with a full-screen error widget made every tab appear "broken"
/// after a single non-fatal error. Subtree-specific recovery should use other APIs
/// (e.g. [ErrorWidget.builder], route-level error handlers, or a small local
/// [StatefulWidget]) instead.
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  void Function(FlutterErrorDetails details)? _previousOnError;

  @override
  void initState() {
    super.initState();
    _previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      _previousOnError?.call(details);
      ErrorLogger.error(
        'Flutter Error: ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
      );
    };
  }

  @override
  void dispose() {
    FlutterError.onError = _previousOnError;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
