class ZalopayResponse {
  final String orderId;
  final String status; // PENDING, PAID, FAILED
  final String paymentUrl;
  final double total;
  final DateTime? expiresAt;

  ZalopayResponse({
    required this.orderId,
    required this.status,
    required this.paymentUrl,
    required this.total,
    this.expiresAt,
  });

  factory ZalopayResponse.fromJson(Map<String, dynamic> json) {
    return ZalopayResponse(
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      paymentUrl: json['paymentUrl'] as String,
      total: (json['total'] as num).toDouble(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }
}
