import 'package:dio/dio.dart';
import 'package:nsapp/core/models/failure.dart';

class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return Failure(message: "Connection timed out. Please check your internet connection.");
      }
      
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic>) {
          // Attempt to extract detail or non_field_errors
          if (data.containsKey('detail')) {
            return Failure(message: data['detail'].toString());
          } else if (data.containsKey('non_field_errors')) {
            return Failure(message: data['non_field_errors'][0].toString());
          } else if (data.containsKey('message')) {
            return Failure(message: data['message'].toString());
          }
          // If it's a field error, join them
          if (data.isNotEmpty) {
            final firstError = data.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return Failure(message: firstError[0].toString());
            }
          }
        }
        return Failure(message: "Server error: ${error.response!.statusCode}");
      }
      
      if (error.type == DioExceptionType.connectionError) {
        return Failure(message: "No internet connection.");
      }
      
      return Failure(message: "An unexpected network error occurred.");
    }
    
    return Failure(message: error.toString());
  }
}
