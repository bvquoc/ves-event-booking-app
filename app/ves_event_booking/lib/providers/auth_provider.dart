import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/google_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleAuthService _googleService = GoogleAuthService();

  User? currentUser;
  String? accessToken;
  String? refreshToken;
  bool isLoading = false;

  bool get isLoggedIn => accessToken != null && currentUser != null;
  static bool isInitialized = false;

  /// Login with email, password
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final auth = await _authService.login(email, password);
      accessToken = auth.accessToken;
      refreshToken = auth.refreshToken;
      await fetchProfile();
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up new user
  Future<void> signup(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signup(email, password);
      // Return {userId}, does not have token.
      // Not automatic login -> back to login page
    } finally {
      _setLoading(false);
    }
  }

  /// Forgot password -> send email reset request
  Future<void> forgotPassword(String email) async {
    await _authService.forgotPassword(email);
  }

  /// Set new password with token
  Future<void> resetPassword(String token, String newPassword) async {
    await _authService.resetPassword(token, newPassword);
  }

  /// Change password while logged in
  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (accessToken == null) throw Exception("Not logged in");
    await _authService.changePassword(accessToken!, oldPassword, newPassword);
  }

  /// Get user profile
  Future<void> fetchProfile() async {
    if (accessToken == null) return;
    final userService = UserService(accessToken!);
    currentUser = await userService.getProfile();
    notifyListeners();
  }

  /// Refresh access with refresh token
  Future<void> refreshAccessToken() async {
    if (refreshToken == null) throw Exception("No refresh token");
    final auth = await _authService.refreshToken(refreshToken!);
    accessToken = auth.accessToken;
    notifyListeners();
  }

  /// Logout 1 session
  Future<void> logout() async {
    if (accessToken != null && refreshToken != null) {
      await _authService.logout(accessToken!, refreshToken!);
    }
    _clearAuth();
  }

  /// Logout all sessions
  Future<void> logoutAll() async {
    if (accessToken != null) {
      await _authService.logoutAll(accessToken!);
    }
    _clearAuth();
  }

  /// Clear state
  void _clearAuth() {
    accessToken = null;
    refreshToken = null;
    currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// Google login session
  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      final auth = await _googleService.signInWithGoogle();

      if (auth != null) {
        accessToken = auth.accessToken;
        refreshToken = auth.refreshToken;
        await fetchProfile();
      } else {
        throw Exception("Đăng nhập Google thất bại hoặc đã bị hủy.");
      }
    } finally {
      _setLoading(false);
    }
  }
}
