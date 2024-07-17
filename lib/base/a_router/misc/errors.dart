/// Thrown when [ARouter] is used incorrectly.
class GoError extends Error {
  /// Constructs a [GoError]
  GoError(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'GoError: $message';
}

/// Thrown when [ARouter] can not handle a user request.
class GoException implements Exception {
  /// Creates an exception with message describing the reason.
  GoException(this.message);

  /// The reason that causes this exception.
  final String message;

  @override
  String toString() => 'GoException: $message';
}
