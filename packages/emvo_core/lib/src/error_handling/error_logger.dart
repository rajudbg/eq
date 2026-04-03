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
  }) => log(
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

/// Widget to catch and handle Flutter errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;
  void Function(FlutterErrorDetails details)? _previousOnError;

  @override
  void initState() {
    super.initState();
    _previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() => _error = details);
      ErrorLogger.error(
        'Flutter Error: ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
      );
      _previousOnError?.call(details);
    };
  }

  @override
  void dispose() {
    FlutterError.onError = _previousOnError;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ?? _defaultErrorWidget(_error!);
    }
    return widget.child;
  }

  Widget _defaultErrorWidget(FlutterErrorDetails error) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'We have logged this error. Please restart the app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _error = null),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
