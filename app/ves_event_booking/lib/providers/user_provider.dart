import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/user/user_model.dart';
import 'package:ves_event_booking/models/user/user_model_update_request.dart';
import 'package:ves_event_booking/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  Future<void> fetchUserInfo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.getMyInfo();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserModelUpdateRequest updatedData) async {
    if (_user == null) {
      _errorMessage = 'User not loaded';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.updateUserById(_user!.id, updatedData);
    } catch (e) {
      _errorMessage = "Error at here";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
