import 'package:ves_event_booking/models/user/role_model.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final DateTime dob;
  final List<RoleModel> roles;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dob: DateTime.parse(json['dob']),
      roles: (json['roles'] as List).map((e) => RoleModel.fromJson(e)).toList(),
    );
  }
}
