import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/employee_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class EmployeeService {
  static const String baseUrl = "http://10.0.2.2:8000/api/employees";

  // ============================================
  // GET ALL EMPLOYEES
  // ============================================
  static Future<List<EmployeeModel>> fetchEmployees() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => EmployeeModel.fromJson(e)).toList();
    }

    return [];
  }

  // ============================================
  // GET ONE
  // ============================================
  static Future<EmployeeModel?> fetchEmployee(int id) async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return EmployeeModel.fromJson(jsonDecode(decoded));
    }

    return null;
  }

  // ============================================
  // CREATE EMPLOYEE
  // ============================================
  static Future<bool> createEmployee({
    required Map<String, String> fields,
    File? avatarImage,
  }) async {
    final uri = Uri.parse("$baseUrl/");

    final res = await ApiClient.sendMultipart((token) async {
      final req = http.MultipartRequest("POST", uri);

      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";

      fields.forEach((key, value) => req.fields[key] = value);

      if (avatarImage != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            "avatar_image",
            avatarImage.path,
          ),
        );
      }

      return req;
    });

    return res.statusCode == 201;
  }

  // ============================================
  // UPDATE EMPLOYEE
  // ============================================
  static Future<bool> updateEmployee({
    required int id,
    required Map<String, String> fields,
    File? avatarImage,
  }) async {
    final uri = Uri.parse("$baseUrl/$id/");

    final res = await ApiClient.sendMultipart((token) async {
      final req = http.MultipartRequest("PUT", uri);

      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";

      fields.forEach((key, value) => req.fields[key] = value);

      if (avatarImage != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            "avatar_image",
            avatarImage.path,
          ),
        );
      }

      return req;
    });

    return res.statusCode == 200;
  }

  // ============================================
  // DELETE EMPLOYEE
  // ============================================
  static Future<bool> deleteEmployee(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 204;
  }
}
