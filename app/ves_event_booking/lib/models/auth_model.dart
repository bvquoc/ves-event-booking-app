import 'user/user_model.dart';

class AuthResponse {
  final UserModel? user; // Login trả về user, Refresh token thì không
  final String accessToken;
  final String? refreshToken; // Refresh token endpoint chỉ trả accessToken mới
  final int expiresIn;

  AuthResponse({
    this.user,
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as int,
    );
  }
}
