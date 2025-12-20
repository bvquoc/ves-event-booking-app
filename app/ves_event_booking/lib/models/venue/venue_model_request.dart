class VenueModelRequest {
  final String name;
  final String address;
  final int capacity;
  final String cityId;

  VenueModelRequest({
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

  factory VenueModelRequest.fromJson(Map<String, dynamic> json) {
    return VenueModelRequest(
      name: json['name'],
      address: json['address'],
      capacity: json['capacity'],
      cityId: json['cityId'],
    );
  }
}
