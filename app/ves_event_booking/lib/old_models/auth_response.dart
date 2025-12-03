class AuthResponse {
  final String accessToken;
  final String refreshToken;

  AuthResponse({required this.accessToken, required this.refreshToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}