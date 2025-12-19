import 'package:ves_event_booking/models/role_model.dart';

class UserModel {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final DateTime dob;
  final List<RoleModel> roles;

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dob: DateTime.parse(json['dob']),
      roles: (json['roles'] as List).map((e) => RoleModel.fromJson(e)).toList(),
    );
  }
}
