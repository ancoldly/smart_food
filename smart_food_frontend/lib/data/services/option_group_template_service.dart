import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/option_group_template_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class OptionGroupTemplateService {
  static const String baseUrl = "http://10.0.2.2:8000/api/products/templates/option-groups";

  static Future<List<OptionGroupTemplateModel>> fetchGroups() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => OptionGroupTemplateModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<OptionGroupTemplateModel?> fetchGroup(int id) async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return OptionGroupTemplateModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<bool> createGroup(Map<String, dynamic> body) async {
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

  static Future<bool> updateGroup(int id, Map<String, dynamic> body) async {
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

  static Future<bool> deleteGroup(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    return res.statusCode == 204;
  }
}
