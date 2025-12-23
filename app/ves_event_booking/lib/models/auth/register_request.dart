class RegisterRequest {
  final String username;
  final String password;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final DateTime dob;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.dob,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      // ISO-8601 format → "2025-12-23"
      'dob': dob.toIso8601String().split('T').first,
    };
  }
}
