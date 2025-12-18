import 'package:dio/dio.dart';
import '../models/auth_model.dart'; // Chứa AuthResponse, UserModel
import 'dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  // 1. Đăng nhập
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/token',
        data: {'email': email, 'password': password},
      );

      // Parse data từ response.data['data']
      return AuthResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      String message = e.error?.toString() ?? e.message ?? 'Lỗi kết nối server';
      throw message;
    } catch (e) {
      throw 'Đã xảy ra lỗi kết nối';
    }
  }

  // 2. Đăng ký
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'phoneNumber': phone,
        },
      );

      return AuthResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error.toString();
    } catch (e) {
      throw 'Đã xảy ra lỗi kết nối';
    }
  }
}
