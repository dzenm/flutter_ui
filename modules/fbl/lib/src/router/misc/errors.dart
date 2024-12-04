/// Thrown when [ARouter] is used incorrectly.
class AError extends Error {
  /// Constructs a [AError]
  AError(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'AError: $message';
}

/// Thrown when [ARouter] can not handle a user request.
class AException implements Exception {
  /// Creates an exception with message describing the reason.
  AException(this.message);

  /// The reason that causes this exception.
  final String message;

  @override
  String toString() => 'AException: $message';
}
