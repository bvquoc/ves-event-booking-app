import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/enums/ticket_status.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';
import 'package:ves_event_booking/models/utils/pagination_response.dart';
import 'package:ves_event_booking/models/purchase/purchase_cancel_request.dart';
import 'package:ves_event_booking/models/purchase/purchase_cancel_response.dart';
import 'package:ves_event_booking/models/purchase/purchase_model.dart';
import 'package:ves_event_booking/models/purchase/purchase_model_request.dart';
import 'package:ves_event_booking/models/ticket/ticket_model.dart';

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

  // POST /tickets/purchase
  Future<PurchaseModel> purchaseTicket(PurchaseModelRequest request) async {
    try {
      final response = await _dio.post(
        '/tickets/purchase',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => PurchaseModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to purchase ticket',
      );
    }
  }

  // PUT /tickets/{ticketId}/cancel
  Future<PurchaseCancelResponse> cancelTicket(
    String ticketId,
    PurchaseCancelRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/tickets/$ticketId/cancel',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => PurchaseCancelResponse.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to cancel ticket',
      );
    }
  }
}
