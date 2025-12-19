class VenueModel {
  final String name;
  final String address;
  final int capacity;
  final String cityId;

  VenueModel({
    required this.name,
    required this.address,
    required this.capacity,
    required this.cityId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'capacity': capacity,
      'cityId': cityId,
    };
  }

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      name: json['name'],
      address: json['address'],
      capacity: json['capacity'],
      cityId: json['cityId'],
    );
  }
}

class VenueSection {
  final String sectionName;
  final List<VenueRow> rows;

  VenueSection({required this.sectionName, required this.rows});

  factory VenueSection.fromJson(Map<String, dynamic> json) {
    return VenueSection(
      sectionName: json['sectionName'],
      rows: (json['rows'] as List).map((e) => VenueRow.fromJson(e)).toList(),
    );
  }
}

class VenueRow {
  final String rowName;
  final List<Seat> seats;

  VenueRow({required this.rowName, required this.seats});

  factory VenueRow.fromJson(Map<String, dynamic> json) {
    return VenueRow(
      rowName: json['rowName'],
      seats: (json['seats'] as List).map((e) => Seat.fromJson(e)).toList(),
    );
  }
}

class Seat {
  final String id;
  final String seatNumber;
  final String status;

  Seat({required this.id, required this.seatNumber, required this.status});

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'],
      seatNumber: json['seatNumber'],
      status: json['status'],
    );
  }
}
