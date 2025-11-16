import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/services/token_storage.dart';

class UserService {
  static const String baseUrl = "http://10.0.2.2:8000/api/users";

  static Future<bool> updateProfile({
    String? fullName,
    String? phone,
    File? avatarFile,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return false;

    final uri = Uri.parse("$baseUrl/me/update/");

    final req = http.MultipartRequest("PUT", uri);

    req.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "multipart/form-data",
    });

    if (fullName != null) req.fields["full_name"] = fullName;
    if (phone != null) req.fields["phone"] = phone;

    if (avatarFile != null) {
      req.files.add(
        await http.MultipartFile.fromPath("avatar", avatarFile.path),
      );
    }

    final streamedRes = await req.send();
    final res = await http.Response.fromStream(streamedRes);

    return res.statusCode == 200;
  }

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      return {"success": false, "message": "Token expired"};
    }

    final url = Uri.parse("$baseUrl/me/change-password/");
    final res = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "old_password": oldPassword,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      }),
    );

    return jsonDecode(res.body);
  }
}
