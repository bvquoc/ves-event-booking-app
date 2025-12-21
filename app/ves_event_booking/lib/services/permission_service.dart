import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/user/permission_mode_request.dart';
import 'package:ves_event_booking/models/user/permission_model.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';

class PermissionService {
  final Dio _dio = DioClient.dio;

  Future<PermissionModel> createPermission(
    PermissionModelRequest request,
  ) async {
    try {
      final response = await _dio.post('/permissions', data: request.toJson());

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => PermissionModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to create permission',
      );
    }
  }

  Future<List<PermissionModel>> getPermissions() async {
    try {
      final response = await _dio.get('/permissions');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) =>
            (json as List).map((e) => PermissionModel.fromJson(e)).toList(),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch permissions',
      );
    }
  }

  Future<void> deletePermission(String permission) async {
    try {
      await _dio.delete('/permissions/$permission');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to delete permission',
      );
    }
  }
}
