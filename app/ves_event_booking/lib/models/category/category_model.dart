class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final int? eventCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.eventCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      icon: json['icon'],
      eventCount: json['eventCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'eventCount': eventCount,
    };
  }
}
