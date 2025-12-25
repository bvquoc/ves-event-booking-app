class TicketModel {
  final String id;

  // Event info
  final String eventId;
  final String eventName;
  final String? eventDescription;
  final String? eventThumbnail;
  final DateTime eventStartDate;
  final DateTime? eventEndDate;

  // Venue info
  final String venueName;
  final String? venueAddress;

  // Ticket type
  final String? ticketTypeId;
  final String ticketTypeName;
  final String? ticketTypeDescription;
  final double? ticketTypePrice;

  // Seat & QR
  final String? seatSectionName;
  final String? seatRowName;
  final String? seatNumber;
  final String qrCode;
  final String? qrCodeImage;

  // Status & lifecycle
  final String status; // ACTIVE, USED, CANCELLED
  final DateTime purchaseDate;
  final DateTime? checkedInAt;

  // Cancellation & refund
  final String? cancellationReason;
  final double? refundAmount;
  final String? refundStatus;
  final DateTime? cancelledAt;

  TicketModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    this.eventDescription,
    this.eventThumbnail,
    required this.eventStartDate,
    this.eventEndDate,
    required this.venueName,
    this.venueAddress,
    this.ticketTypeId,
    required this.ticketTypeName,
    this.ticketTypeDescription,
    this.ticketTypePrice,
    this.seatSectionName,
    this.seatRowName,
    this.seatNumber,
    required this.qrCode,
    this.qrCodeImage,
    required this.status,
    required this.purchaseDate,
    this.checkedInAt,
    this.cancellationReason,
    this.refundAmount,
    this.refundStatus,
    this.cancelledAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      eventId: json['eventId'],
      eventName: json['eventName'],
      eventDescription: json['eventDescription'],
      eventThumbnail: json['eventThumbnail'],
      eventStartDate: DateTime.parse(json['eventStartDate']),
      eventEndDate: json['eventEndDate'] != null
          ? DateTime.parse(json['eventEndDate'])
          : null,
      venueName: json['venueName'],
      venueAddress: json['venueAddress'],
      ticketTypeId: json['ticketTypeId'],
      ticketTypeName: json['ticketTypeName'],
      ticketTypeDescription: json['ticketTypeDescription'],
      ticketTypePrice: (json['ticketTypePrice'] as num?)?.toDouble(),
      seatNumber: json['seatNumber'],
      seatSectionName: json['seatSectionName'],
      seatRowName: json['seatRowName'],
      qrCode: json['qrCode'],
      qrCodeImage: json['qrCodeImage'],
      status: json['status'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'])
          : null,
      cancellationReason: json['cancellationReason'],
      refundAmount: (json['refundAmount'] as num?)?.toDouble(),
      refundStatus: json['refundStatus'],
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
    );
  }
}
