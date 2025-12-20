import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';
import 'package:ves_event_booking/models/city/city_model.dart';
import 'package:ves_event_booking/models/city/city_model_request.dart';

class CityService {
  final Dio _dio = DioClient.dio;

  // GET /cities/{cityId}
  Future<CityModel> getCityById(String cityId) async {
    try {
      final response = await _dio.get('/cities/$cityId');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => CityModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to get city');
    }
  }

  // DELETE /cities/{cityId}
  Future<ApiResponse<Object>> deleteCity(String cityId) async {
    try {
      final response = await _dio.delete('/cities/$cityId');

      return ApiResponse.fromJson(response.data, (_) => Object());
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete city');
    }
  }

  // GET /cities
  Future<List<CityModel>> getCities() async {
    try {
      final response = await _dio.get('/cities');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => (json as List).map((e) => CityModel.fromJson(e)).toList(),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to get cities');
    }
  }

  // POST /cities
  Future<CityModel> createCity(CityModelRequest request) async {
    try {
      final response = await _dio.post('/cities', data: request.toJson());

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => CityModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to create city');
    }
  }

  // PUT /cities/{cityId}
  Future<CityModel> updateCity(String cityId, CityModelRequest request) async {
    try {
      final response = await _dio.put(
        '/cities/$cityId',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => CityModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to update city');
    }
  }
}
