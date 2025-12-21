import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/option_template_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class OptionTemplateService {
  static const String baseUrl = "http://10.0.2.2:8000/api/products/templates/options";

  static Future<List<OptionTemplateModel>> fetchOptions() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => OptionTemplateModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<bool> createOption(Map<String, dynamic> body) async {
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

  static Future<bool> updateOption(int id, Map<String, dynamic> body) async {
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

  static Future<bool> deleteOption(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    return res.statusCode == 204;
  }
}
