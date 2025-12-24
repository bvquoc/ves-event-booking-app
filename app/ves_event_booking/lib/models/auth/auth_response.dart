class AuthResponse {
  final String token;
  final bool authenticated;
  final List<String> roles;

  AuthResponse({
    required this.token,
    required this.authenticated,
    required this.roles,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      authenticated: json['authenticated'] as bool,
      roles: List<String>.from(json['roles'] as List<dynamic>),
    );
  }
}
