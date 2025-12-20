import 'package:ves_event_booking/models/user/role_model.dart';

class UserModel {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;
  final DateTime? dob;
  final List<RoleModel> roles;

  UserModel({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.dob,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      roles: (json['roles'] as List).map((e) => RoleModel.fromJson(e)).toList(),
    );
  }
}
