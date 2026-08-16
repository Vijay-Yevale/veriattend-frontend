// lib/core/errors/failures.dart

// Failures are what provider receives from repository
// and converts into UI error messages

abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  String toString() => message;
}

// 400 → bad input
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message}) : super(statusCode: 400);
}

// 401 → wrong credentials / token expired
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message}) : super(statusCode: 401);
}

// 403 → not allowed — e.g. a verification token that doesn't belong to
// this account, or a face embedding that doesn't match the enrolled one
class ForbiddenFailure extends Failure {
  const ForbiddenFailure({required super.message}) : super(statusCode: 403);
}

// 404 → resource not found
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message}) : super(statusCode: 404);
}

// 409 → duplicate email or PRN
class ConflictFailure extends Failure {
  const ConflictFailure({required super.message}) : super(statusCode: 409);
}

// 500 → server crash
class ServerFailure extends Failure {
  const ServerFailure({required super.message}) : super(statusCode: 500);
}

// No internet
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

// JSON parse failed
class ParseFailure extends Failure {
  const ParseFailure({super.message = 'Failed to parse response'});
}
