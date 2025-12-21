class PermissionModelRequest {
  final String name;
  final String description;

  PermissionModelRequest({required this.name, required this.description});

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}
