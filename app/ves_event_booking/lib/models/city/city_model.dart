class CityModel {
  final String id;
  final String name;
  final String slug;
  final int? eventCount;

  CityModel({
    required this.id,
    required this.name,
    required this.slug,
    this.eventCount,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      eventCount: json['eventCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug, 'eventCount': eventCount};
  }
}
