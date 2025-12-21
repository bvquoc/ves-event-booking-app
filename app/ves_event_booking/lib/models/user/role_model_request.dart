class RoleModelRequest {
  final String name;
  final String description;
  final List<String> permissions;

  RoleModelRequest({
    required this.name,
    required this.description,
    required this.permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'permissions': permissions,
    };
  }
}
