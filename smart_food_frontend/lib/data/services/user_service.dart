import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/services/api_client.dart';

class UserService {
  static const String baseUrl = "http://10.0.2.2:8000/api/users";

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final url = Uri.parse("$baseUrl/admin/users/");

    final res = await ApiClient.send((token) {
      return http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }

    return [];
  }

  static Future<bool> updateProfile({
    String? fullName,
    String? phone,
    File? avatarFile,
  }) async {
    final uri = Uri.parse("$baseUrl/me/update/");

    final res = await ApiClient.sendMultipart((token) async {
      final req = http.MultipartRequest("PUT", uri);

      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";

      if (fullName != null) req.fields["full_name"] = fullName;
      if (phone != null) req.fields["phone"] = phone;

      if (avatarFile != null) {
        req.files.add(
          await http.MultipartFile.fromPath("avatar", avatarFile.path),
        );
      }

      return req;
    });

    return res.statusCode == 200;
  }

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse("$baseUrl/me/change-password/");

    final res = await ApiClient.send((token) {
      return http.put(
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
    });

    return jsonDecode(res.body);
  }
}
