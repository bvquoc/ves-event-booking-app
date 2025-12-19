import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import '../old_models/auth_response.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<Map<String, dynamic>> signup(String email, String password) async {
    final response = await _dio.post(
      '/auth/signup',
      data: {'email': email, 'password': password},
    );
    return response.data; // {"userId": "..."}
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/password/forgot', data: {"email": email});
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _dio.post(
      '/auth/password/reset',
      data: {"token": token, "newPassword": newPassword},
    );
  }

  Future<void> changePassword(
    String accessToken,
    String oldPassword,
    String newPassword,
  ) async {
    await _dio.post(
      '/auth/password/change',
      data: {"oldPassword": oldPassword, "newPassword": newPassword},
      options: Options(headers: {"Authorization": "Bearer $accessToken"}),
    );
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/token/refresh',
      data: {"refreshToken": refreshToken},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<void> logout(String accessToken, String refreshToken) async {
    await _dio.post(
      '/auth/logout',
      data: {"refreshToken": refreshToken},
      options: Options(headers: {"Authorization": "Bearer $accessToken"}),
    );
  }

  Future<void> logoutAll(String accessToken) async {
    await _dio.post(
      '/auth/logout-all',
      options: Options(headers: {"Authorization": "Bearer $accessToken"}),
    );
  }
}
