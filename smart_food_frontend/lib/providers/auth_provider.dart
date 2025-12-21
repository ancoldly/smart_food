import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/user_model.dart';
import 'package:smart_food_frontend/data/services/auth_service.dart';
import 'package:smart_food_frontend/data/services/merchant_storage.dart';
import 'package:smart_food_frontend/data/services/token_storage.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';
import 'package:smart_food_frontend/main.dart'; // để lấy navigatorKey

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  Future<bool> login(
      BuildContext context, String email, String password) async {
    final result = await _authService.login(email, password);

    if (result["success"] == true) {
      final tokens = result["data"];

      await TokenStorage.saveTokens(tokens["access"], tokens["refresh"]);

      final profile = await AuthService.getProfile();
      if (profile != null) {
        _user = profile;
        notifyListeners();

        _syncToUserProvider(profile);

        // ignore: use_build_context_synchronously
        checkRoleUser(context, profile.role);

        return true;
      }
    }
    return false;
  }

  Future<Map<String, dynamic>?> register({
    required String email,
    required String username,
    required String fullName,
    required String phone,
    required String password,
    required String password2,
  }) async {
    return await _authService.register(
      email: email,
      username: username,
      phone: phone,
      fullName: fullName,
      password: password,
      password2: password2,
    );
  }

  Future<bool> autoLogin(BuildContext context) async {
    final access = await TokenStorage.getAccessToken();
    if (access == null) return false;

    final isExpired = await TokenStorage.isAccessTokenExpired();

    if (isExpired) {
      final refresh = await TokenStorage.getRefreshToken();
      if (refresh == null) return false;

      final newAccess = await _authService.refreshAccessToken(refresh);
      if (newAccess == null) return false;

      await TokenStorage.saveTokens(newAccess, refresh);
    }

    final profile = await AuthService.getProfile();
    if (profile == null) return false;

    _user = profile;
    notifyListeners();

    _syncToUserProvider(profile);

    // ignore: use_build_context_synchronously
    checkRoleUser(context, profile.role);

    return true;
  }

  Future<void> logout() async {
    await _authService.logout();
    await TokenStorage.clearTokens();

    _user = null;
    notifyListeners();

    _clearUserProvider();
  }

  void _syncToUserProvider(UserModel profile) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      Provider.of<UserProvider>(ctx, listen: false).syncUser(profile);
    }
  }

  void _clearUserProvider() {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      Provider.of<UserProvider>(ctx, listen: false).clearUser();
    }
  }

  void checkRoleUser(BuildContext context, String role) async {
    if (role == "merchant") {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      await storeProvider.loadMyStore();

      final store = storeProvider.myStore;

      if (store == null) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, AppRoutes.onStepZero);
        return;
      }

      if (store.status == 2) {
        final seen = await MerchantStorage.isWelcomeSeen(user!.id);

        if (!seen) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(context, AppRoutes.merchantStart);
          return;
        }
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, AppRoutes.mainMerchant);
        return;
      }

      if (store.status == 4) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, AppRoutes.mainMerchant);
        return;
      }
    }

    if (role == "customer") {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, AppRoutes.main);
      return;
    }

    if (role == "admin") {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      return;
    }

    if (role == "shipper") {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, AppRoutes.main);
      return;
    }
  }
}
