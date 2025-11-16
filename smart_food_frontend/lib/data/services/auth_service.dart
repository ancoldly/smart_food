import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/user_model.dart';
import 'package:smart_food_frontend/data/services/token_storage.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8000/api/users";

  Future<Map<String, dynamic>?> register({
    required String email,
    required String username,
    required String password,
    required String password2,
    String? fullName,
  }) async {
    final url = Uri.parse("$baseUrl/register/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "username": username,
        "full_name": fullName ?? "",
        "password": password,
        "password2": password2,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    return {
      "error": jsonDecode(response.body),
      "status": response.statusCode,
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return {
        "success": true,
        "data": jsonDecode(response.body),
      };
    }

    return {
      "success": false,
      "message": jsonDecode(response.body),
    };
  }

  Future<String?> refreshAccessToken(String refreshToken) async {
    final url = Uri.parse("$baseUrl/token/refresh/");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refreshToken}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["access"];
    }

    return null; // refresh token expired
  }

  static Future<UserModel?> getProfile() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return null;

    final url = Uri.parse("$baseUrl/me/");
    final res = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (res.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(res.body));
    }

    return null;
  }

  Future<bool> logout() async {
    final refresh = await TokenStorage.getRefreshToken();
    final url = Uri.parse("$baseUrl/logout/");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refresh}),
    );

    if (res.statusCode == 205) {
      await TokenStorage.clearTokens();
      return true;
    }

    return false;
  }
}
