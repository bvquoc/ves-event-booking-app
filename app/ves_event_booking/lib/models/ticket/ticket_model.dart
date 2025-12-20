class TicketModel {
  final String id;
  final String eventId;
  final String eventName;
  final String eventThumbnail;
  final DateTime eventStartDate;
  final String venueName;
  final String ticketTypeName;
  final String? seatNumber;
  final String status;
  final String qrCode;
  final DateTime purchaseDate;

  TicketModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.eventThumbnail,
    required this.eventStartDate,
    required this.venueName,
    required this.ticketTypeName,
    this.seatNumber,
    required this.status,
    required this.qrCode,
    required this.purchaseDate,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      eventThumbnail: json['eventThumbnail'] as String,
      eventStartDate: DateTime.parse(json['eventStartDate']),
      venueName: json['venueName'] as String,
      ticketTypeName: json['ticketTypeName'] as String,
      seatNumber: json['seatNumber'], // nullable
      status: json['status'] as String,
      qrCode: json['qrCode'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate']),
    );
  }
}

// 2. Model cho Đơn hàng sau khi mua (Order/Purchase Response)
class OrderModel {
  final String orderId;
  final String status; // pending, completed
  final String eventId;
  final String eventName;
  final String paymentUrl;
  final double total;
  final String currency;
  final DateTime expiresAt;

  OrderModel({
    required this.orderId,
    required this.status,
    required this.eventId,
    required this.eventName,
    required this.paymentUrl,
    required this.total,
    required this.currency,
    required this.expiresAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      paymentUrl: json['paymentUrl'] as String,
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String,
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}
