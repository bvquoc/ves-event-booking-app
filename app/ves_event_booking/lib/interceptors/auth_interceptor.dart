import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  static const _publicEndpoints = ['/auth/token', '/auth/register'];
  static const _logoutEndpoint = '/auth/logout';

  bool _isPublicEndpoint(String path) {
    return _publicEndpoints.any((e) => path.contains(e));
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // ✅ Handle logout success
    if (response.requestOptions.path.contains(_logoutEndpoint)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
