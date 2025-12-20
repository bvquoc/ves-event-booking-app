class UserModelCreateRequest {
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final DateTime dob;

  UserModelCreateRequest({
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.dob,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      // Backend expects yyyy-MM-dd
      'dob': dob.toIso8601String().split('T').first,
    };
  }
}
