import 'event_model.dart';
import 'ticket_type_model.dart';

// 1. Model cho Vé của người dùng (My Tickets)
class TicketModel {
  final String id;
  final String orderId;
  final EventModel event; // Sự kiện tương ứng
  final TicketTypeModel ticketType; // Loại vé
  final String qrCode;
  final String? qrCodeImage; // Chỉ có ở chi tiết vé
  final String status; // active, used, cancelled
  final DateTime purchaseDate;
  final String? seatNumber;
  final DateTime? checkedInAt; // Chỉ có ở chi tiết vé

  // Thông tin hủy vé (Nullable)
  final String? cancellationReason;
  final double? refundAmount;
  final String? refundStatus;

  TicketModel({
    required this.id,
    required this.orderId,
    required this.event,
    required this.ticketType,
    required this.qrCode,
    this.qrCodeImage,
    required this.status,
    required this.purchaseDate,
    this.seatNumber,
    this.checkedInAt,
    this.cancellationReason,
    this.refundAmount,
    this.refundStatus,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      // Event trong vé thường là dạng tóm tắt, nhưng dùng chung EventModel vẫn ổn
      event: EventModel.fromJson(json['event'] as Map<String, dynamic>),
      ticketType: TicketTypeModel.fromJson(
        json['ticketType'] as Map<String, dynamic>,
      ),
      qrCode: json['qrCode'] as String,
      qrCodeImage: json['qrCodeImage'] as String?,
      status: json['status'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate']),
      seatNumber: json['seatNumber'] as String?,
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'])
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      refundAmount: json['refundAmount'] != null
          ? (json['refundAmount'] as num).toDouble()
          : null,
      refundStatus: json['refundStatus'] as String?,
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
