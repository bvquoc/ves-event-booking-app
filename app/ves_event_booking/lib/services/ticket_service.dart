import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/enums/ticket_status.dart';
import 'package:ves_event_booking/models/ticket/cancel_ticket_response.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';
import 'package:ves_event_booking/models/utils/pagination_response.dart';
import 'package:ves_event_booking/models/ticket/ticket_model.dart';
import 'package:ves_event_booking/models/zalopay/zalopay_model_request.dart';
import 'package:ves_event_booking/models/zalopay/zalopay_response.dart';

class TicketService {
  final Dio _dio = DioClient.dio;

  Future<PageResult<TicketModel>> getTickets(
    TicketStatus status,
    PaginationRequest pageable,
  ) async {
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

  // GET /tickets/{ticketId}
  Future<TicketModel> getTicketById(String ticketId) async {
    try {
      final response = await _dio.get('/tickets/$ticketId');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => TicketModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to get ticket');
    }
  }

  Future<CancelTicketResponse> cancelTicket(
    String ticketId,
    String reason,
  ) async {
    try {
      final response = await _dio.put(
        '/tickets/$ticketId/cancel',
        data: {'reason': reason},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => CancelTicketResponse.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch vouchers',
      );
    }
  }

  Future<ZalopayResponse> purchaseTicket(ZalopayModelRequest request) async {
    try {
      final response = await _dio.post(
        '/tickets/purchase',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => ZalopayResponse.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch vouchers',
      );
    }
  }
}
