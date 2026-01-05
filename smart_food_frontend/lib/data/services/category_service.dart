import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/category_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class CategoryService {
  static const String baseUrl = "http://10.0.2.2:8000/api/categories";

  // Merchant: list all categories in current store
  static Future<List<CategoryModel>> fetchCategories() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    }

    return [];
  }

  // Get one category
  static Future<CategoryModel?> fetchCategory(int id) async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return CategoryModel.fromJson(jsonDecode(decoded));
    }

    return null;
  }

  // Create category (multipart for optional image)
  static Future<bool> createCategory({
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    final uri = Uri.parse("$baseUrl/");

    final res = await ApiClient.sendMultipart((token) async {
      final req = http.MultipartRequest("POST", uri);

      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";

      fields.forEach((key, value) => req.fields[key] = value);

      if (imageFile != null) {
        req.files.add(
          await http.MultipartFile.fromPath("image", imageFile.path),
        );
      }

      return req;
    });

    return res.statusCode == 201;
  }

  // Update category
  static Future<bool> updateCategory({
    required int id,
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    final uri = Uri.parse("$baseUrl/$id/");

    final res = await ApiClient.sendMultipart((token) async {
      final req = http.MultipartRequest("PATCH", uri);

      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";

      fields.forEach((key, value) => req.fields[key] = value);

      if (imageFile != null) {
        req.files.add(
          await http.MultipartFile.fromPath("image", imageFile.path),
        );
      }

      return req;
    });

    return res.statusCode == 200;
  }

  // Delete category
  static Future<bool> deleteCategory(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 204;
  }

  // Public: categories by store id
  static Future<List<CategoryModel>> fetchCategoriesByStore(int storeId) async {
    final res = await http.get(Uri.parse("$baseUrl/public/$storeId/"));
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    }
    return [];
  }
}
