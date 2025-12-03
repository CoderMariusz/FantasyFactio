/// Generic Result type for error handling in use cases
/// Represents either a successful value (Success) or a failure (Failure)
abstract class Result<T, E> {
  const Result();

  /// Creates a successful result with a value
  factory Result.success(T value) = Success<T, E>;

  /// Creates a failed result with an error
  factory Result.failure(E error) = Failure<T, E>;

  /// Check if this result is a success
  bool get isSuccess => this is Success<T, E>;

  /// Check if this result is a failure
  bool get isFailure => this is Failure<T, E>;

  /// Get the success value, or null if this is a failure
  T? get valueOrNull => isSuccess ? (this as Success<T, E>).value : null;

  /// Get the error, or null if this is a success
  E? get errorOrNull => isFailure ? (this as Failure<T, E>).error : null;

  /// Execute a function based on whether this is a success or failure
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(E error) onFailure,
  }) {
    if (this is Success<T, E>) {
      return onSuccess((this as Success<T, E>).value);
    } else {
      return onFailure((this as Failure<T, E>).error);
    }
  }
}

/// Represents a successful result containing a value
class Success<T, E> extends Result<T, E> {
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed result containing an error
class Failure<T, E> extends Result<T, E> {
  final E error;

  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}
