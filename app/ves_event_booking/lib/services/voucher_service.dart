import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';
import 'package:ves_event_booking/models/voucher/voucher_model.dart';
import 'package:ves_event_booking/models/voucher/voucher_status_model.dart';
import 'package:ves_event_booking/models/voucher/voucher_validate_model.dart';
import 'package:ves_event_booking/models/voucher/voucher_validate_request.dart';

class VoucherService {
  final Dio _dio = DioClient.dio;

  Future<List<VoucherModel>> getVouchers() async {
    try {
      final response = await _dio.get('/vouchers');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => (json as List).map((e) => VoucherModel.fromJson(e)).toList(),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch vouchers',
      );
    }
  }

  Future<VoucherValidateModel> validateVoucher(
    VoucherValidateRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/vouchers/validate',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => VoucherValidateModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to validate voucher',
      );
    }
  }

  Future<List<VoucherStatusModel>> getMyVouchers({String? status}) async {
    try {
      final response = await _dio.get(
        '/vouchers/my-vouchers',
        queryParameters: {if (status != null) 'status': status},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) =>
            (json as List).map((e) => VoucherStatusModel.fromJson(e)).toList(),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch my vouchers',
      );
    }
  }
}
