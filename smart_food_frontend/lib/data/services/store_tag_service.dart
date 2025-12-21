import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/models/store_tag_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';
import 'package:smart_food_frontend/data/services/store_service.dart';

class StoreTagService {
  static const String _baseUrl = "${StoreService.baseUrl}/tags";

  static Future<List<StoreTagModel>> fetchTags() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$_baseUrl/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => StoreTagModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<StoreTagModel?> createTag(Map<String, dynamic> body) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$_baseUrl/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode(body),
      );
    });
    if (res.statusCode == 201) {
      final decoded = utf8.decode(res.bodyBytes);
      return StoreTagModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<StoreTagModel?> updateTag(int id, Map<String, dynamic> body) async {
    final res = await ApiClient.send((token) {
      return http.patch(
        Uri.parse("$_baseUrl/$id/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode(body),
      );
    });
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return StoreTagModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<bool> deleteTag(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$_baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    return res.statusCode == 204;
  }
}
