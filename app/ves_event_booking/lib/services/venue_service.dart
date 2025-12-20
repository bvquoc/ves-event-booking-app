import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';
import 'package:ves_event_booking/models/venue/venue_model.dart';
import 'package:ves_event_booking/models/venue/venue_model_request.dart';
import 'package:ves_event_booking/models/venue/venue_seat_map_model.dart';

class VenueService {
  final Dio _dio = DioClient.dio;

  Future<List<VenueModel>> getVenues() async {
    try {
      final response = await _dio.get('/venues');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => (json as List).map((e) => VenueModel.fromJson(e)).toList(),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load venues');
    }
  }

  Future<VenueModel> getVenueById(String venueId) async {
    try {
      final response = await _dio.get('/venues/$venueId');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => VenueModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to get venue');
    }
  }

  // DELETE /venues/{venueId}
  Future<ApiResponse<Object>> deleteVenue(String venueId) async {
    try {
      final response = await _dio.delete('/venues/$venueId');

      return ApiResponse.fromJson(response.data, (_) => Object());
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete venue');
    }
  }

  // GET /venues/{venueId}/seats?eventId=xxx
  Future<VenueSeatMapModel> getVenueSeats({
    required String venueId,
    required String eventId,
  }) async {
    try {
      final response = await _dio.get(
        '/venues/$venueId/seats',
        queryParameters: {'eventId': eventId},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => VenueSeatMapModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load venue seats',
      );
    }
  }

  // POST /venues
  Future<VenueModel> createVenue(VenueModelRequest request) async {
    try {
      final response = await _dio.post('/venues', data: request.toJson());

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => VenueModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to create venue');
    }
  }

  // PUT /venues/{venueId}
  Future<VenueModel> updateVenue(
    String venueId,
    VenueModelRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/venues/$venueId',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => VenueModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to update venue');
    }
  }
}
