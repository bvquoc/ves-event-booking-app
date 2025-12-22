import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';
import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/models/event/event_model_request.dart';
import 'package:ves_event_booking/models/ticket/ticket_type_model.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';
import 'package:ves_event_booking/models/utils/pagination_response.dart';

class EventService {
  final Dio _dio = DioClient.dio;

  Future<EventModel> createEvent(EventModelRequest payload) async {
    try {
      final response = await _dio.post('/events', data: payload.toJson());

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => EventModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to create event');
    }
  }

  // DELETE
  Future<ApiResponse> deleteEvent(String eventId) async {
    try {
      final res = await _dio.delete('/events/$eventId');
      return ApiResponse.fromJson(res.data, (_) => null);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete event');
    }
  }

  // GET
  Future<EventModel> getEvent(String eventId) async {
    try {
      final res = await _dio.get('/events/$eventId');

      final apiResponse = ApiResponse.fromJson(
        res.data,
        (json) => EventModel.fromJson(json),
      );
      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to get event');
    }
  }

  // GET tickets of event
  Future<ApiResponse<List<TicketTypeModel>>> getTicketsByEvent(
    String eventId,
  ) async {
    try {
      final res = await _dio.get('/events/$eventId/tickets');

      return ApiResponse.fromJson(
        res.data,
        (json) =>
            (json as List).map((e) => TicketTypeModel.fromJson(e)).toList(),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to get event tickets',
      );
    }
  }

  // PUT
  Future<ApiResponse<EventModel>> updateEvent(
    String eventId,
    EventModelRequest payload,
  ) async {
    try {
      final res = await _dio.put('/events/$eventId', data: payload.toJson());

      return ApiResponse.fromJson(
        res.data,
        (json) => EventModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to update event');
    }
  }

  Future<PageResult<EventModel>> getEvents({
    String? category,
    String? city,
    bool? trending,
    String? startDate,
    String? endDate,
    String? search,
    String? sortBy,
    PaginationRequest? pageable,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (category != null) 'category': category,
        if (city != null) 'city': city,
        if (trending != null) 'trending': trending,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (search != null) 'search': search,
        if (sortBy != null) 'sortBy': sortBy,
        if (pageable != null) ...pageable.toQueryParams(),
      };

      final Response response = await _dio.get(
        '/events',
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => PageResult.fromJson(json, (e) => EventModel.fromJson(e)),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception('Failed to load events');
    }
  }
}
