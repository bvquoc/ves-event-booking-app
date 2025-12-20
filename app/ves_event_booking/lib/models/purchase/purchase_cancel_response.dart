class PurchaseCancelResponse {
  final String ticketId;
  final String status;
  final double refundAmount;
  final double refundPercentage;
  final String refundStatus;
  final DateTime cancelledAt;
  final String message;

  PurchaseCancelResponse({
    required this.ticketId,
    required this.status,
    required this.refundAmount,
    required this.refundPercentage,
    required this.refundStatus,
    required this.cancelledAt,
    required this.message,
  });

  factory PurchaseCancelResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseCancelResponse(
      ticketId: json['ticketId'],
      status: json['status'],
      refundAmount: (json['refundAmount'] as num).toDouble(),
      refundPercentage: (json['refundPercentage'] as num).toDouble(),
      refundStatus: json['refundStatus'],
      cancelledAt: DateTime.parse(json['cancelledAt']),
      message: json['message'],
    );
  }
}
