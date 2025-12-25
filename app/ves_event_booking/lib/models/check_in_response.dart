class CheckInResponse {
  final String? ticketId;
  final String? status; // "ACTIVE"
  final String? message; // Thông báo từ server
  final TicketDetails? ticketDetails;

  CheckInResponse({
    this.ticketId,
    this.status,
    this.message,
    this.ticketDetails,
  });

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      ticketId: json['ticketId'],
      status: json['status'],
      message: json['message'],
      ticketDetails: json['ticketDetails'] != null
          ? TicketDetails.fromJson(json['ticketDetails'])
          : null,
    );
  }
}

class TicketDetails {
  final String id;
  final UserInfo? user;
  final EventInfo? event;
  final SeatInfo? seat;
  final TicketTypeInfo? ticketType;

  TicketDetails({
    required this.id,
    this.user,
    this.event,
    this.seat,
    this.ticketType,
  });

  factory TicketDetails.fromJson(Map<String, dynamic> json) {
    return TicketDetails(
      id: json['id'],
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
      event: json['event'] != null ? EventInfo.fromJson(json['event']) : null,
      seat: json['seat'] != null ? SeatInfo.fromJson(json['seat']) : null,
      ticketType: json['ticketType'] != null
          ? TicketTypeInfo.fromJson(json['ticketType'])
          : null,
    );
  }
}

class UserInfo {
  final String fullName;
  final String email;

  UserInfo({required this.fullName, required this.email});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      fullName: json['fullName'] ?? 'Unknown',
      email: json['email'] ?? '',
    );
  }
}

class EventInfo {
  final String name;
  final String venueName;

  EventInfo({required this.name, required this.venueName});

  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      name: json['name'] ?? '',
      venueName: json['venueName'] ?? '',
    );
  }
}

class SeatInfo {
  final String seatNumber;
  final String? section;
  final String? row;

  SeatInfo({required this.seatNumber, this.section, this.row});

  factory SeatInfo.fromJson(Map<String, dynamic> json) {
    return SeatInfo(
      seatNumber: json['seatNumber'] ?? '',
      section: json['section'],
      row: json['row'],
    );
  }
}

class TicketTypeInfo {
  final String name;

  TicketTypeInfo({required this.name});

  factory TicketTypeInfo.fromJson(Map<String, dynamic> json) {
    return TicketTypeInfo(name: json['name'] ?? '');
  }
}
