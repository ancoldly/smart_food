import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/user_model.dart';
import 'package:smart_food_frontend/data/services/user_service.dart';
import 'package:smart_food_frontend/data/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadUser(UserModel profile) async {
    _isLoading = true;
    notifyListeners();

    final fetched = await AuthService.getProfile();
    _user = fetched;

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    File? avatarFile,
  }) async {
    _isLoading = true;
    notifyListeners();

    final success = await UserService.updateProfile(
      fullName: fullName,
      phone: phone,
      avatarFile: avatarFile,
    );

    if (success) {
      final updated = await AuthService.getProfile();
      _user = updated;
    }

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await UserService.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    _isLoading = false;
    notifyListeners();
    return result;
  }

  void syncUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
