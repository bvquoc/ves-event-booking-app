import '../city/city_model.dart';

class VenueModel {
  final String id;
  final String name;
  final String address;
  final int capacity;
  final CityModel city;

  VenueModel({
    required this.id,
    required this.name,
    required this.address,
    required this.capacity,
    required this.city,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      capacity: json['capacity'] as int,
      city: CityModel.fromJson(json['city']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'capacity': capacity,
      'city': city.toJson(),
    };
  }
}
