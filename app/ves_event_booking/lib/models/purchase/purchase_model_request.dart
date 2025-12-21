class PurchaseModelRequest {
  final String eventId;
  final String ticketTypeId;
  final int quantity;
  final List<String> seatIds;
  final String voucherCode;
  final String paymentMethod;

  PurchaseModelRequest({
    required this.eventId,
    required this.ticketTypeId,
    required this.quantity,
    required this.seatIds,
    required this.voucherCode,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'ticketTypeId': ticketTypeId,
      'quantity': quantity,
      'seatIds': seatIds,
      'voucherCode': voucherCode,
      'paymentMethod': paymentMethod,
    };
  }
}
