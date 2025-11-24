import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/user_model.dart';
import 'package:smart_food_frontend/data/services/user_service.dart';
import 'package:smart_food_frontend/data/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  // ------------------------------
  // USER INFO (CURRENT USER)
  // ------------------------------
  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ------------------------------
  // ADMIN: LIST USERS
  // ------------------------------
  List<UserModel> _allUsers = [];
  List<UserModel> get allUsers => _allUsers;

  bool _loadingAllUsers = false;
  bool get loadingAllUsers => _loadingAllUsers;

  // =====================================================
  // LOAD CURRENT USER PROFILE
  // =====================================================
  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    final fetched = await AuthService.getProfile();
    _user = fetched;

    _isLoading = false;
    notifyListeners();
  }

  // =====================================================
  // UPDATE PROFILE
  // =====================================================
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

  // =====================================================
  // CHANGE PASSWORD
  // =====================================================
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

  // =====================================================
  // ADMIN: LOAD ALL USERS
  // =====================================================
  Future<void> loadAllUsers() async {
    _loadingAllUsers = true;
    notifyListeners();

    final data = await UserService.getAllUsers();

    _allUsers = data
        .map((e) => UserModel.fromJson(e))
        .toList();

    _loadingAllUsers = false;
    notifyListeners();
  }

  // =====================================================
  // LOCAL SYNC & CLEAR
  // =====================================================
  void syncUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
