class UserModelUpdateRequest {
  final String? password;
  final String? firstName;
  final String? lastName;
  final DateTime? dob;
  final List<String>? roles;

  UserModelUpdateRequest({
    this.password,
    this.firstName,
    this.lastName,
    this.dob,
    this.roles,
  });

  Map<String, dynamic> toJson() {
    return {
      if (password != null) 'password': password,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (dob != null) 'dob': dob!.toIso8601String().split('T').first,
      if (roles != null) 'roles': roles,
    };
  }
}
