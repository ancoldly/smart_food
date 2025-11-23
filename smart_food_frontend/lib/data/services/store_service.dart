import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class StoreService {
  static const String baseUrl = "http://10.0.2.2:8000/api/stores";

  // =============================
  //   GET ALL STORES (OF USER)
  // =============================
  static Future<List<StoreModel>> fetchStores() async {
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
  //   CREATE STORE (MULTIPART)
  // =============================
  static Future<bool> createStore({
    required Map<String, String> fields,
    File? backgroundImage,
  }) async {
    final uri = Uri.parse("$baseUrl/");

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
  //   (Xử lý ảnh giống lúc tạo store)
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
        Uri.parse("$baseUrl/$id/approve/"),
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
        Uri.parse("$baseUrl/$id/reject/"),
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
