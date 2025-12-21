import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/user/role_model.dart';
import 'package:ves_event_booking/models/user/role_model_request.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';

class RoleService {
  final Dio _dio = DioClient.dio;

  Future<List<RoleModel>> getRoles() async {
    try {
      final response = await _dio.get('/roles');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => (json as List).map((e) => RoleModel.fromJson(e)).toList(),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch roles');
    }
  }

  Future<RoleModel> createRole(RoleModelRequest request) async {
    try {
      final response = await _dio.post('/roles', data: request.toJson());

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => RoleModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to create role');
    }
  }

  Future<void> deleteRole(String role) async {
    try {
      await _dio.delete('/roles/$role');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete role');
    }
  }
}
