import 'package:dio/dio.dart';
import '../models/user.dart';

class UserService {
  final Dio _dio;

  UserService(String accessToken)
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'http://10.0.2.2:8080/api',
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

  Future<User> getProfile() async {
    final response = await _dio.get('/users/me');
    return User.fromJson(response.data);
  }

  Future<User> updateProfile(Map<String, dynamic> updates) async {
    final response = await _dio.patch('/users/me', data: updates);
    return User.fromJson(response.data);
  }
}
