class PurchaseModel {
  final String orderId;
  final String status;
  final String paymentUrl;
  final double total;
  final DateTime expiresAt;

  PurchaseModel({
    required this.orderId,
    required this.status,
    required this.paymentUrl,
    required this.total,
    required this.expiresAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      orderId: json['orderId'],
      status: json['status'],
      paymentUrl: json['paymentUrl'],
      total: (json['total'] as num).toDouble(),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}
