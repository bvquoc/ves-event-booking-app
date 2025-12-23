class ZalopayModelRequest {
  final String eventId;
  final String ticketTypeId;
  final int quantity;
  final List<String>? seatIds;
  final String? voucherCode;
  final String paymentMethod; // ZALOPAY, CREDIT_CARD, etc.

  ZalopayModelRequest({
    required this.eventId,
    required this.ticketTypeId,
    required this.quantity,
    this.seatIds,
    this.voucherCode,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'ticketTypeId': ticketTypeId,
      'quantity': quantity,
      if (seatIds != null) 'seatIds': seatIds,
      if (voucherCode != null) 'voucherCode': voucherCode,
      'paymentMethod': paymentMethod,
    };
  }
}
