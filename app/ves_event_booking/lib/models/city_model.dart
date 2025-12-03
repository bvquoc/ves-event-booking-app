class CityModel {
  final String id;
  final String name;
  final String slug;
  final int eventCount;

  CityModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.eventCount,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      eventCount: json['eventCount'] as int,
    );
  }
}
