class VenueSeatModel {
  final String id;
  final String seatNumber;
  final String status; // AVAILABLE, BOOKED, etc.

  VenueSeatModel({
    required this.id,
    required this.seatNumber,
    required this.status,
  });

  factory VenueSeatModel.fromJson(Map<String, dynamic> json) {
    return VenueSeatModel(
      id: json['id'] as String,
      seatNumber: json['seatNumber'] as String,
      status: json['status'] as String,
    );
  }
}
