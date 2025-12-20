import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';
import 'package:ves_event_booking/models/user/user_model.dart';
import 'package:ves_event_booking/models/user/user_model_create_request.dart';
import 'package:ves_event_booking/models/user/user_model_update_request.dart';

class UserService {
  final Dio _dio = DioClient.dio;

  // GET /users/my-info
  Future<UserModel> getMyInfo() async {
    try {
      final response = await _dio.get('/users/my-info');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => UserModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to get user info',
      );
    }
  }

  // POST /users
  Future<UserModel> createUser(UserModelCreateRequest payload) async {
    try {
      final response = await _dio.post('/users', data: payload.toJson());

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => UserModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to create user');
    }
  }

  // PUT /users/{userId}
  Future<UserModel> updateUserById(
    String userId,
    UserModelUpdateRequest payload,
  ) async {
    try {
      final response = await _dio.put('/users/$userId', data: payload.toJson());

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => UserModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to update user');
    }
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

  // GET /users/{userId}
  Future<UserModel> getUserById(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => UserModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch user');
    }
  }

  // DELETE /users/{userId}
  Future<ApiResponse<String>> deleteUser(String userId) async {
    try {
      final response = await _dio.delete('/users/$userId');

      return ApiResponse.fromJson(response.data, (json) => json as String);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete user');
    }
  }
}
