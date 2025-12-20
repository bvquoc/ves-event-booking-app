import 'package:dio/dio.dart';
import 'package:ves_event_booking/config/zalopay_config.dart';
import 'package:ves_event_booking/models/zalopay/zalopay_response.dart';
import 'package:ves_event_booking/utils/zalopay_helper.dart';

class ZaloPayService {
  final Dio _dio = Dio();

  /// Create ZaloPay order with only amount
  Future<ZaloPayResponse> createOrder(String appUser, int amount) async {
    // 1️⃣ Build full ZaloPay request using helper
    final order = ZaloPayHelper.createOrderRequest(appUser, amount);
    final payload = order.toJson();

    // 2️⃣ Send request to ZaloPay
    final response = await _dio.post(
      ZaloPayConfig.createOrderUrl,
      data: payload, // Dio will encode form data correctly
      options: Options(headers: {'Content-Type': ZaloPayConfig.contentType}),
    );

    // 3️⃣ Dio already parses JSON → use response.data
    return ZaloPayResponse.fromJson(Map<String, dynamic>.from(response.data));
  }
}
