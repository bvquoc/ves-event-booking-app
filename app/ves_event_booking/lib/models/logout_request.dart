class LogoutRequest {
  final String token;

  LogoutRequest({required this.token});

  Map<String, dynamic> toJson() {
    return {'token': token};
  }
}
