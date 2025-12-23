import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/auth/auth_response.dart';
import 'package:ves_event_booking/models/auth/login_request.dart';
import 'package:ves_event_booking/models/auth/register_request.dart';
import 'package:ves_event_booking/models/logout_request.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  // 1. Đăng nhập
  Future<String> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/token', data: request.toJson());

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => AuthResponse.fromJson(json),
      );
      return apiResponse.result.token;
    } on DioException catch (e) {
      throw e.error.toString();
    } catch (e) {
      throw e.toString();
    }
  }

  // 2. Đăng ký
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => AuthResponse.fromJson(json),
      );
      return apiResponse.result;
    } on DioException catch (e) {
      throw e.error.toString();
    } catch (e) {
      throw 'Đã xảy ra lỗi kết nối';
    }
  }

  /// POST /auth/logout
  Future<void> logout(LogoutRequest request) async {
    try {
      await _dio.post('/auth/logout', data: request.toJson());
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to logout');
    }
  }
}
