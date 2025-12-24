import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ves_event_booking/models/auth/login_request.dart';
import 'package:ves_event_booking/models/auth/register_request.dart';
import '../models/user/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  static final AuthProvider instance = AuthProvider._internal();
  AuthProvider._internal();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Xử lý Đăng nhập
  Future<List<String>> login(String email, String password) async {
    _setLoading(true);
    try {
      final authResponse = await _authService.login(
        LoginRequest(username: email, password: password),
      );

      // Lưu token vào máy
      await _saveToken(authResponse.token);

      _errorMessage = null;
      notifyListeners();
      return authResponse.roles; // Đăng nhập thành công
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return []; // Đăng nhập thất bại
    } finally {
      _setLoading(false);
    }
  }

  // Xử lý Đăng ký
  Future<bool> register(RegisterRequest request) async {
    _setLoading(true);
    try {
      final authResponse = await _authService.register(request);

      await _saveToken(authResponse.token);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Lưu token
  Future<void> _saveToken(String access) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', access);
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
