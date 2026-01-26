import 'package:dio/dio.dart';

class ServerNotReachableException implements Exception {}

class NoInternetException implements Exception {}

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, {this.statusCode});

  factory ServerException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return ServerException("Request to server was cancelled");
      case DioExceptionType.connectionTimeout:
        return ServerException("Connection timeout");
      case DioExceptionType.receiveTimeout:
        return ServerException("Receive timeout");
      case DioExceptionType.sendTimeout:
        return ServerException("Send timeout");
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          // Handle specific error structure from requirements
          // "details": [ { "field": "...", "message": "..." } ]
          if (data.containsKey('details')) {
            final details = data['details'];
            if (details is List && details.isNotEmpty) {
              return ServerException(
                details[0]['message'] ?? "Unknown Validation Error",
              );
            }
          }
          // "code_error": "...", "message": ""
          if (data.containsKey('message') &&
              data['message'] != null &&
              data['message'].isNotEmpty) {
            return ServerException(data['message']);
          }
          if (data.containsKey('error')) {
            return ServerException(data['error'].toString());
          }
        }
        return ServerException(
          "Server error with status code: ${error.response?.statusCode}",
        );
      case DioExceptionType.unknown:
        if (error.error is FormatException) {
          return ServerException("Bad response format");
        }
        return ServerException("Unexpected error occurred");
      default:
        return ServerException("Something went wrong");
    }
  }
}
