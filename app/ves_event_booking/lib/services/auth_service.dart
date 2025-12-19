import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/auth_model.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  // 1. Đăng nhập
  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/token',
        data: {'username': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final result = data['result'];

        if (result != null && result['token'] != null) {
          return result['token'];
        } else {
          throw 'API không trả về Token';
        }
      } else {
        throw 'Lỗi kết nối: ${response.statusCode}';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        throw errorData?['message'] ?? 'Lỗi server (${e.response?.statusCode})';
      } else {
        print(e);
        throw 'Lỗi kết nối: ${e.message}';
      }
    } catch (e) {
      throw e.toString();
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
