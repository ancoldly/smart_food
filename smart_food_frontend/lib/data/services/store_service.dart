import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class StoreService {
  static const String baseUrl = "http://10.0.2.2:8000/api/stores";

  // =============================
  //   ADMIN: GET ALL STORES
  // =============================
  static Future<List<StoreModel>> fetchStoresAdmin() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/admin/all/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => StoreModel.fromJson(e)).toList();
    }
    return [];
  }

  // =============================
  //   USER: GET MY STORE (ONE)
  // =============================
  static Future<StoreModel?> fetchMyStore() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/me/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final body = utf8.decode(res.bodyBytes).trim();

      // ===========================
      // case 1: backend trả null
      // case 2: backend trả "" hoặc "null"
      // ===========================
      if (body.isEmpty || body == "null") {
        return null;
      }

      final data = jsonDecode(body);
      if (data == null) return null;

      return StoreModel.fromJson(data);
    }

    return null;
  }

  // =============================
  //   CREATE STORE (MULTIPART)
  // =============================
  static Future<bool> createStore({
    required Map<String, String> fields,
    File? backgroundImage,
  }) async {
    final uri = Uri.parse("$baseUrl/create/");

    final res = await ApiClient.sendMultipart((token) async {
      final req = http.MultipartRequest("POST", uri);

      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";

      // Add fields
      fields.forEach((key, value) {
        req.fields[key] = value;
      });

      // Add image
      if (backgroundImage != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            "background_image",
            backgroundImage.path,
          ),
        );
      }

      return req;
    });

    return res.statusCode == 201;
  }

  // =============================
  //   UPDATE STORE (MULTIPART)
  // =============================
  static Future<bool> updateStore({
    required int id,
    required Map<String, String> fields,
    File? backgroundImage,
  }) async {
    final uri = Uri.parse("$baseUrl/$id/");

    final res = await ApiClient.sendMultipart((token) async {
      final req = http.MultipartRequest("PATCH", uri);

      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";

      // Add text fields
      fields.forEach((key, value) {
        req.fields[key] = value;
      });

      // Add image if exists
      if (backgroundImage != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            "background_image",
            backgroundImage.path,
          ),
        );
      }

      return req;
    });

    return res.statusCode == 200;
  }

  // =============================
  //   DELETE STORE
  // =============================
  static Future<bool> deleteStore(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 204;
  }

  // =============================
  //   ADMIN: APPROVE STORE
  // =============================
  static Future<bool> approveStore(int id) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/admin/$id/approve/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 200;
  }

  // =============================
  //   ADMIN: REJECT STORE
  // =============================
  static Future<bool> rejectStore(int id) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/admin/$id/reject/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 200;
  }

  // =============================
  //   MERCHANT: TOGGLE STORE
  // =============================
  static Future<bool> toggleStore(int id) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/$id/toggle/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 200;
  }
}
