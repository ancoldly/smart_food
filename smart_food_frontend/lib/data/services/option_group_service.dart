import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/option_group_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class OptionGroupService {
  static const String baseUrl = "http://10.0.2.2:8000/api/products/option-groups";

  static Future<List<OptionGroupModel>> fetchOptionGroups() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => OptionGroupModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<OptionGroupModel?> fetchOptionGroup(int id) async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return OptionGroupModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<bool> createOptionGroup(Map<String, dynamic> body) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    });
    return res.statusCode == 201;
  }

  static Future<bool> updateOptionGroup(int id, Map<String, dynamic> body) async {
    final res = await ApiClient.send((token) {
      return http.patch(
        Uri.parse("$baseUrl/$id/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    });
    return res.statusCode == 200;
  }

  static Future<bool> deleteOptionGroup(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    return res.statusCode == 204;
  }
}
