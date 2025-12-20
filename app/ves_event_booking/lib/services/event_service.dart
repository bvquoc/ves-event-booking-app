import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';
import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/models/event/event_model_request.dart';
import 'package:ves_event_booking/models/ticket/ticket_type_model.dart';

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
  Future<ApiResponse<EventModel>> getEvent(String eventId) async {
    try {
      final res = await _dio.get('/events/$eventId');

      return ApiResponse.fromJson(
        res.data,
        (json) => EventModel.fromJson(json),
      );
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
}
