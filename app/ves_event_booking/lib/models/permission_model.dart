class PermissionModel {
  final String name;
  final String description;

  PermissionModel({required this.name, required this.description});

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      name: json['name'],
      description: json['description'],
    );
  }
}
