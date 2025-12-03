import 'package:dio/dio.dart';
import 'package:tourguide/core/endpoints.dart';
class DioClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          baseUrl, // keda adytha el baseUrl 3la el dio kolha bdl ma ab3to kol shwya
      headers: {
        "Content-Type": 'application/json',
      }, // keda adytha el headers 3la el dio kolha bdl ma ab3to kol shwya
    ),
  );

  DioClient() {
    _dio.options.followRedirects = false; // bymn3 el dio tn2lny hya
    _dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (
              options,
              handler,
            ) // keda b2olw w ana bb3t el token astna2 el atsal m3 el server
            async {
              return handler.next(options);
            },
      ),
    );
  }

  Dio get dio => _dio; // 3mlna getter 3lhan nwslo mn kol mkan by sehwla
}