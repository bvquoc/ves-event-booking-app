import 'package:ves_event_booking/models/permission_model.dart';

class RoleModel {
  final String name;
  final String description;
  final List<PermissionModel> permissions;

  RoleModel({
    required this.name,
    required this.description,
    required this.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      name: json['name'],
      description: json['description'],
      permissions: (json['permissions'] as List)
          .map((e) => PermissionModel.fromJson(e))
          .toList(),
    );
  }
}
