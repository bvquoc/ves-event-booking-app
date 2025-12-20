class ZaloPayResponse {
  final int returnCode;
  final String returnMessage;
  final int subReturnCode;
  final String subReturnMessage;
  final String? zpTransToken;
  final String? orderUrl;
  final String? orderToken;
  final String? qrCode;

  ZaloPayResponse({
    required this.returnCode,
    required this.returnMessage,
    required this.subReturnCode,
    required this.subReturnMessage,
    this.zpTransToken,
    this.orderUrl,
    this.orderToken,
    this.qrCode,
  });

  factory ZaloPayResponse.fromJson(Map<String, dynamic> json) {
    return ZaloPayResponse(
      returnCode: json['return_code'],
      returnMessage: json['return_message'],
      subReturnCode: json['sub_return_code'],
      subReturnMessage: json['sub_return_message'],
      zpTransToken: json['zp_trans_token'],
      orderUrl: json['order_url'],
      orderToken: json['order_token'],
      qrCode: json['qr_code'],
    );
  }

  bool get isSuccess => returnCode == 1 && subReturnCode == 1;
}
