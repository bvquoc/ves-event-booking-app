class SeatMapModel {
  final String venueId;
  final String venueName;
  final String eventId;
  final List<SectionModel> sections;

  SeatMapModel({
    required this.venueId,
    required this.venueName,
    required this.eventId,
    required this.sections,
  });

  factory SeatMapModel.fromJson(Map<String, dynamic> json) {
    return SeatMapModel(
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      eventId: json['eventId'] as String,
      sections: (json['sections'] as List)
          .map((e) => SectionModel.fromJson(e))
          .toList(),
    );
  }
}

class SectionModel {
  final String id;
  final String name;
  final List<RowModel> rows;

  SectionModel({required this.id, required this.name, required this.rows});

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      rows: (json['rows'] as List).map((e) => RowModel.fromJson(e)).toList(),
    );
  }
}

class RowModel {
  final String row; // Tên hàng ghế (A, B, C...)
  final List<SeatModel> seats;

  RowModel({required this.row, required this.seats});

  factory RowModel.fromJson(Map<String, dynamic> json) {
    return RowModel(
      row: json['row'] as String,
      seats: (json['seats'] as List).map((e) => SeatModel.fromJson(e)).toList(),
    );
  }
}

class SeatModel {
  final String id;
  final String number;
  final String status; // available, sold, reserved, blocked
  final double price;
  final String ticketTypeId;

  SeatModel({
    required this.id,
    required this.number,
    required this.status,
    required this.price,
    required this.ticketTypeId,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      id: json['id'] as String,
      number: json['number'] as String,
      status: json['status'] as String,
      price: (json['price'] as num).toDouble(),
      ticketTypeId: json['ticketTypeId'] as String,
    );
  }
}
