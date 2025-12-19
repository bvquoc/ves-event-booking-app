import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/api_response.dart';
import 'package:ves_event_booking/models/category_model.dart';

class CategoryService {
  final Dio _dio = DioClient.dio;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final Response response = await _dio.get('/categories');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => (json as List).map((e) => CategoryModel.fromJson(e)).toList(),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load categories',
      );
    }
  }
}
