import 'package:dio/dio.dart';
import 'package:ves_event_booking/old_models/auth_response.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class GoogleAuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080/api'));

  Future<Map<String, dynamic>> linkGoogle(
    String idToken,
    String accessToken,
  ) async {
    final response = await _dio.post(
      '/oauth/google/link',
      data: {"idToken": idToken},
      options: Options(
        headers: {
          "Authorization": "Bearer $accessToken", // link with logged in account
        },
      ),
    );
    return response.data;
  }

  /// Send idToken only when user login with Google
  Future<Map<String, dynamic>> loginWithGoogle(String? idToken) async {
    final response = await _dio.post(
      '/oauth/google/link',
      data: {"idToken": idToken},
    );
    return response.data;
  }

  /// Google Auth by back-end
  Future<AuthResponse?> signInWithGoogle() async {
    print("STUCK HERE !!!");
    // === Bước 1 & 2: Lấy URL xác thực từ back-end ===
    // C -> A: GET /oauth/google/url
    final response = await _dio.get('/oauth/google/url');
    final String authUrl = response.data['url'];

    // === Bước 3 & 4: Mở trình duyệt và chờ redirect ===
    // C -> G: Mở trang đăng nhập của Google
    // G -> C: Redirect về với code
    final String callbackUrlScheme = 'com.example.ves_event_booking';

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: callbackUrlScheme,
      );

      // === Bước 5: Lấy 'code' từ URL kết quả ===
      // result sẽ có dạng: myapp://callback?code=...&scope=...
      final Uri resultUri = Uri.parse(result);
      final String? code = resultUri.queryParameters['code'];

      if (code != null) {
        // === Bước 6 & 7: Gửi 'code' về cho back-end ===
        // C -> A: GET /oauth/google/callback?code=...
        final loginResponse = await _dio.get(
          '/oauth/google/callback',
          queryParameters: {'code': code},
        );

        // A -> C: Trả về token
        return AuthResponse.fromJson(loginResponse.data);
      } else {
        // Không nhận được authorization code từ Google
        return null;
      }
    } on Exception catch (e) {
      // Xử lý các lỗi có thể xảy ra (ví dụ: người dùng đóng cửa sổ trình duyệt)
      print('Lỗi xác thực: $e');
      return null;
    }
  }
}
