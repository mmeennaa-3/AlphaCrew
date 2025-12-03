import 'package:dio/dio.dart';
import 'api_execption.dart';
import 'dio_client.dart';

class ApiService {
  final DioClient _dioClient = DioClient();

  /// CRUD METHODS

 // # get
  Future<dynamic> get({required String endPoint}) async {
    try {
      final response = await _dioClient.dio.get(endPoint);
      return response.data;
    } on DioException catch (e) {
      return ApiExceptions.handleError(e);
    }
  }

}