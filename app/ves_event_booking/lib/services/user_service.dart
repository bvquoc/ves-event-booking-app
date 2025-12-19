import 'package:dio/dio.dart';
import 'package:ves_event_booking/models/api_response.dart';
import 'package:ves_event_booking/models/user_model.dart';
import '../old_models/user.dart';

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

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _dio.get('/users');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => (json as List).map((e) => UserModel.fromJson(e)).toList(),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load users');
    }
  }
}
