import 'package:dio/dio.dart';

import 'api_error.dart';
class ApiExceptions {
  static ApiError handleError(DioException error){
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    if (data is Map<String, dynamic > && data['message'] != null) {
      return ApiError(message: data['message'], statusCode: statusCode );
    }
    if(statusCode == 302){
      throw ApiError(message: 'This Email Already Taken');
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
    return ApiError(message: "Bad Connection");        
      case DioExceptionType.badResponse:
    return ApiError(message: error.toString());        
      default:
    //   return ApiError(message: error.toString());
      return ApiError(message: "Something went wrong");
    }
  }
}