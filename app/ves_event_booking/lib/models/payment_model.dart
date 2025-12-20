class PaymentModel {
  final String orderId;
  final String status;

  final String eventId;
  final String eventName;

  final TicketSummary ticketType;
  final int quantity;

  final double subtotal;
  final double discount;
  final double total;
  final String currency;

  final String paymentUrl;
  final DateTime expiresAt;
  final DateTime createdAt;

  PaymentModel({
    required this.orderId,
    required this.status,
    required this.eventId,
    required this.eventName,
    required this.ticketType,
    required this.quantity,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.currency,
    required this.paymentUrl,
    required this.expiresAt,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      orderId: json['orderId'],
      status: json['status'],
      eventId: json['eventId'],
      eventName: json['eventName'],
      ticketType: TicketSummary.fromJson(json['ticketType']),
      quantity: json['quantity'],
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'],
      paymentUrl: json['paymentUrl'],
      expiresAt: DateTime.parse(json['expiresAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class TicketSummary {
  final String id;
  final String name;
  final double price;

  TicketSummary({
    required this.id,
    required this.name,
    required this.price,
  });

  factory TicketSummary.fromJson(Map<String, dynamic> json) {
    return TicketSummary(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
    );
  }
}


enum PaymentMethod {
  vnpay,
  vietQR,
  shopeePay,
  momo,
  zaloPay,
  card,
}

extension PaymentMethodX on PaymentMethod {
  String get apiValue {
    switch (this) {
      case PaymentMethod.card:
        return 'credit_card';
      case PaymentMethod.vietQR:
        return 'bank_transfer';
      default:
        return 'e_wallet';
    }
  }

  String get title {
    switch (this) {
      case PaymentMethod.vnpay:
        return 'VNPay';
      case PaymentMethod.vietQR:
        return 'VietQR';
      case PaymentMethod.shopeePay:
        return 'ShopeePay';
      case PaymentMethod.momo:
        return 'MoMo';
      case PaymentMethod.zaloPay:
        return 'ZaloPay';
      case PaymentMethod.card:
        return 'Thẻ ghi nợ / Thẻ tín dụng';
    }
  }
}
