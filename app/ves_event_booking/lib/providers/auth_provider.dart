import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Xử lý Đăng nhập
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final accessToken = await _authService.login(email, password);

      // Lưu token vào máy
      await _saveToken(accessToken, null);

      _errorMessage = null;
      notifyListeners();
      return true; // Đăng nhập thành công
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false; // Đăng nhập thất bại
    } finally {
      _setLoading(false);
    }
  }

  // Xử lý Đăng ký
  Future<bool> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    _setLoading(true);
    try {
      final authResponse = await _authService.register(
        email: email,
        password: password,
        fullName: name,
        phone: phone,
      );

      await _saveToken(authResponse.accessToken, authResponse.refreshToken);
      _currentUser = authResponse.user;
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
  Future<void> _saveToken(String access, String? refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', access);
    if (refresh != null) {
      await prefs.setString('refreshToken', refresh);
    }
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
