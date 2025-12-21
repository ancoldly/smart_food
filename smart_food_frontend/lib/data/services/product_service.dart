import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class ProductService {
  static const String baseUrl = "http://10.0.2.2:8000/api/products";

  static Future<List<ProductModel>> fetchProducts() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<ProductModel?> fetchProduct(int id) async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return ProductModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<bool> createProduct({
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    final uri = Uri.parse("$baseUrl/");
    final res = await ApiClient.sendMultipart((token) async {
      final req = http.MultipartRequest("POST", uri);
      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";
      fields.forEach((k, v) => req.fields[k] = v);
      if (imageFile != null) {
        req.files.add(await http.MultipartFile.fromPath("image", imageFile.path));
      }
      return req;
    });
    return res.statusCode == 201;
  }

  static Future<bool> updateProduct({
    required int id,
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    final uri = Uri.parse("$baseUrl/$id/");
    final res = await ApiClient.sendMultipart((token) async {
      final req = http.MultipartRequest("PATCH", uri);
      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";
      fields.forEach((k, v) => req.fields[k] = v);
      if (imageFile != null) {
        req.files.add(await http.MultipartFile.fromPath("image", imageFile.path));
      }
      return req;
    });
    return res.statusCode == 200;
  }

  static Future<bool> deleteProduct(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    return res.statusCode == 204;
  }

  // PUBLIC: products by store (optional category)
  static Future<List<ProductModel>> fetchProductsByStore({
    required int storeId,
    int? categoryId,
  }) async {
    final uri = Uri.parse("$baseUrl/public/$storeId/").replace(
      queryParameters: categoryId != null ? {"category": "$categoryId"} : null,
    );
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }
}
