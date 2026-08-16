// lib/core/errors/exceptions.dart

// Thrown by datasource when API call fails
// statusCode and message come directly from your backend response

class ServerException implements Exception {
  final String message;
  final int statusCode;

  const ServerException({required this.message, required this.statusCode});
}

// Thrown when device has no internet
class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection'});
}

// Thrown when JSON parsing fails
class ParseException implements Exception {
  final String message;

  const ParseException({this.message = 'Failed to parse response'});
}
