import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/api_response.dart';
import 'package:ves_event_booking/models/event_model.dart';
import 'package:ves_event_booking/models/event_model_request.dart';

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
}
