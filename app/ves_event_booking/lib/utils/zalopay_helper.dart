import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:ves_event_booking/models/zalopay/zalopay_callback_response.dart';
import 'package:ves_event_booking/models/zalopay/zalopay_request.dart';

import '../config/zalopay_config.dart';
import 'crypto_helper.dart';

class ZaloPayHelper {
  /// Create full ZaloPay order payload
  /// Only requires amount
  static ZaloPayRequest createOrderRequest(String appUser, int amount) {
    final appId = ZaloPayConfig.appId;

    // current time in milliseconds
    final appTime = DateTime.now().millisecondsSinceEpoch.toString();

    // app_trans_id format: yyMMdd_random
    final date = DateFormat('yyMMdd').format(DateTime.now());
    final appTransId = '${date}_${DateTime.now().millisecondsSinceEpoch}';

    final bankCode = 'zalopayapp';
    final embedData = jsonEncode({});
    final item = jsonEncode([]);

    final callbackUrl = 'https://your-domain.com/zalopay/callback';

    final description = 'ZaloPayDemo - Thanh toán cho đơn hàng #$appTransId';

    /// mac = HMAC_SHA256(key1,
    /// app_id|app_trans_id|app_user|amount|app_time|embed_data|item)
    final rawMac =
        '$appId|$appTransId|$appUser|$amount|$appTime|$embedData|$item';

    final mac = CryptoHelper.hmacSha256(ZaloPayConfig.key1, rawMac);

    return ZaloPayRequest(
      app_id: appId,
      app_user: appUser,
      app_time: appTime,
      amount: amount.toString(),
      app_trans_id: appTransId,
      bank_code: bankCode,
      embed_data: embedData,
      item: item,
      callback_url: callbackUrl,
      description: description,
      mac: mac,
    );
  }

  /// Check Zalopay callback validity
  /// [callbackData] - the received callback response
  /// [key] - your secret key (key2)
  static bool isValidCallback(ZalopayCallbackResponse callbackData) {
    final key2 = ZaloPayConfig.key2;

    // Use existing CryptoHelper
    final digest = CryptoHelper.hmacSha256(key2, callbackData.data);

    // Compare digest with mac
    return digest == callbackData.mac;
  }
}
