import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/enums/ticket_status.dart';
import 'package:ves_event_booking/models/api_response.dart';
import 'package:ves_event_booking/models/pagination_request.dart';
import 'package:ves_event_booking/models/pagination_response.dart';
import 'package:ves_event_booking/models/ticket_model.dart';

class TicketService {
  final Dio _dio = DioClient.dio;

  Future<PageResult<TicketModel>> getTickets({
    required TicketStatus status,
    required PaginationRequest pageable,
  }) async {
    try {
      final response = await _dio.get(
        '/tickets',
        queryParameters: {'status': status.value, ...pageable.toQueryParams()},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => PageResult.fromJson(json, (e) => TicketModel.fromJson(e)),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load tickets');
    }
  }
}
