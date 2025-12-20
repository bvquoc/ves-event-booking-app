// ignore_for_file: non_constant_identifier_names

class ZaloPayRequest {
  final String app_id; //: 2553,
  final String app_user; //: "ZaloPayDemo",
  final String app_time; //: 1660717311101,
  final String amount; //: 10000,
  final String app_trans_id; //: "220817_1660717311101",
  final String bank_code; //: "zalopayapp",
  final String embed_data; //: "{}",
  final String item; //: "[]",
  final String callback_url; //: "<https://domain.com/callback>",
  final String description;
  //: "ZaloPayDemo - Thanh toán cho đơn hàng #220817_1660717311101",
  final String mac;

  ZaloPayRequest({
    required this.app_id,
    required this.app_user,
    required this.app_time,
    required this.amount,
    required this.app_trans_id,
    required this.bank_code,
    required this.embed_data,
    required this.item,
    required this.callback_url,
    required this.description,
    required this.mac,
  });

  Map<String, dynamic> toJson() {
    return {
      'app_id': app_id,
      'app_user': app_user,
      'app_time': app_time,
      'amount': amount,
      'app_trans_id': app_trans_id,
      'bank_code': bank_code,
      'embed_data': embed_data,
      'item': item,
      'callback_url': callback_url,
      'description': description,
      'mac': mac,
    };
  }
}
