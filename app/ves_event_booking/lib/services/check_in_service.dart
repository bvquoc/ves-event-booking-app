import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/dio_client.dart';
import 'package:ves_event_booking/models/check_in_response.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';

class CheckInService {
  final Dio _dio = DioClient.dio;

  Future<CheckInResponse> checkInTicket(String qrCode) async {
    try {
      final response = await _dio.post(
        '/admin/tickets/check-in',
        data: {'qrCode': qrCode},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => CheckInResponse.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      // Xử lý lỗi từ server (ví dụ: vé không tồn tại, vé đã check-in rồi)
      throw Exception(e.response?.data?['message'] ?? 'Lỗi khi check-in vé');
    }
  }
}
