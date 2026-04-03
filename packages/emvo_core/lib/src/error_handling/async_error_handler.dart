import 'package:flutter/material.dart';
import 'error_logger.dart';

extension AsyncErrorHandler<T> on Future<T> {
  Future<T?> handleError({
    String? operationName,
    VoidCallback? onError,
  }) async {
    try {
      return await this;
    } catch (e, stackTrace) {
      ErrorLogger.error(
        operationName ?? 'Async operation failed',
        error: e,
        stackTrace: stackTrace,
      );
      onError?.call();
      return null;
    }
  }
}

/// Mixin for safe async operations in widgets
mixin SafeAsyncOperations<T extends StatefulWidget> on State<T> {
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> safeRun(Future<void> Function() operation) async {
    if (_isDisposed) return;
    try {
      await operation();
    } catch (e, stackTrace) {
      ErrorLogger.error('Safe operation failed',
          error: e, stackTrace: stackTrace);
    }
  }

  void safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }
}
