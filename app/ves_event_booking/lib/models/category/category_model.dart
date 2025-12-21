class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final int? eventCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.eventCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String,
      eventCount: json['eventCount'],
    );
  }
}
