import 'package:dio/dio.dart';
import 'package:ves_event_booking/interceptors/auth_interceptor.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://ves-booking.io.vn/api',
      contentType: 'application/json',
    ),
  )..interceptors.add(AuthInterceptor());

  static Dio get dio => _dio;
}
