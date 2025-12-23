class CancelTicketResponse {
  final String reason;

  CancelTicketResponse({required this.reason});

  factory CancelTicketResponse.fromJson(Map<String, dynamic> json) {
    return CancelTicketResponse(reason: json['reason']);
  }
}
