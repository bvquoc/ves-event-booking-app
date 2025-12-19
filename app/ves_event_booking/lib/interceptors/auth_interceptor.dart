import 'package:dio/dio.dart';
import 'package:ves_event_booking/providers/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  static const _publicEndpoints = ['/auth/token', '/auth/register'];

  bool _isPublicEndpoint(String path) {
    return _publicEndpoints.any((e) => path.contains(e));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = AuthProvider.instance.accessToken;

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token invalid / expired
      AuthProvider.instance.accessToken = null;

      // TODO: notify UI or navigate to login
      // NavigationService.logout();
    }

    handler.next(err);
  }
}
