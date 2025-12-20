class ZalopayConfirmRequest {
  final int returnCode;
  final String returnMessage;

  ZalopayConfirmRequest({
    required this.returnCode,
    required this.returnMessage,
  });

  factory ZalopayConfirmRequest.fromJson(Map<String, dynamic> json) {
    return ZalopayConfirmRequest(
      returnCode: json['return_code'],
      returnMessage: json['return_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'return_code': returnCode, 'return_message': returnMessage};
  }
}
