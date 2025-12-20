class ZalopayCallbackResponse {
  final String data;
  final String mac;
  final int type;

  ZalopayCallbackResponse({
    required this.data,
    required this.mac,
    required this.type,
  });

  factory ZalopayCallbackResponse.fromJson(Map<String, dynamic> json) {
    return ZalopayCallbackResponse(
      data: json['data'],
      mac: json['mac'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data, 'mac': mac, 'type': type};
  }
}
