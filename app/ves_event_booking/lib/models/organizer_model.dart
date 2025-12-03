class OrganizerModel {
  final String id;
  final String name;
  final String logo;

  OrganizerModel({required this.id, required this.name, required this.logo});

  factory OrganizerModel.fromJson(Map<String, dynamic> json) {
    return OrganizerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String,
    );
  }
}
