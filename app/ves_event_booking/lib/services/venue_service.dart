import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/api_response.dart';
import 'package:ves_event_booking/models/venue_model.dart';

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
}
