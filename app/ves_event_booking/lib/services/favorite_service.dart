import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';
import 'package:ves_event_booking/models/utils/pagination_response.dart';

class FavoriteService {
  final Dio _dio = DioClient.dio;

  Future<void> addToFavorites(String eventId) async {
    try {
      await _dio.post('/favorites/$eventId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to add event to favorites',
      );
    }
  }

  Future<PageResult<EventModel>> getFavoriteEvents({
    required PaginationRequest pageable,
  }) async {
    try {
      final response = await _dio.get(
        '/favorites',
        queryParameters: pageable.toQueryParams(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => PageResult.fromJson(json, (e) => EventModel.fromJson(e)),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch favorite events',
      );
    }
  }

  Future<void> removeFromFavorites(String eventId) async {
    try {
      await _dio.delete('/favorites/$eventId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to remove event from favorites',
      );
    }
  }
}
