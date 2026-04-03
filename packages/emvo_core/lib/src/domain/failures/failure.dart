/// Base type for recoverable domain / data errors, typically used with
/// `Either<Failure, T>` from `fpdart`.
abstract class Failure implements Exception {
  const Failure();

  String get message;
}

/// Generic failure with a user- or developer-facing message.
class GenericFailure extends Failure {
  const GenericFailure(this.message);

  @override
  final String message;

  @override
  String toString() => 'GenericFailure: $message';
}

/// Local cache / asset / offline storage failure.
class CacheFailure extends Failure {
  const CacheFailure(this.message);

  @override
  final String message;

  @override
  String toString() => 'CacheFailure: $message';
}

/// Remote / server / AI backend failure.
class ServerFailure extends Failure {
  const ServerFailure(this.message);

  @override
  final String message;

  @override
  String toString() => 'ServerFailure: $message';
}
