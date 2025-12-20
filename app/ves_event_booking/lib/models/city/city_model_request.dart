class CityModelRequest {
  final String name;
  final String slug;

  CityModelRequest({required this.name, required this.slug});

  Map<String, dynamic> toJson() {
    return {'name': name, 'slug': slug};
  }
}
