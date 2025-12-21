class VoucherValidateRequest {
  final String voucherCode;
  final String eventId;
  final String ticketTypeId;
  final int quantity;

  VoucherValidateRequest({
    required this.voucherCode,
    required this.eventId,
    required this.ticketTypeId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'voucherCode': voucherCode,
      'eventId': eventId,
      'ticketTypeId': ticketTypeId,
      'quantity': quantity,
    };
  }
}
