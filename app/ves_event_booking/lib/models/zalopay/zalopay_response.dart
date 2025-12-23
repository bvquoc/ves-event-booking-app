class ZalopayResponse {
  final String orderId;
  final String status; // PENDING, PAID, FAILED
  final String paymentUrl;
  final double total;
  final DateTime expiresAt;

  ZalopayResponse({
    required this.orderId,
    required this.status,
    required this.paymentUrl,
    required this.total,
    required this.expiresAt,
  });

  factory ZalopayResponse.fromJson(Map<String, dynamic> json) {
    return ZalopayResponse(
      orderId: json['orderId'],
      status: json['status'],
      paymentUrl: json['paymentUrl'],
      total: (json['total'] as num).toDouble(),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}
