import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/services/api_client.dart';

class AdminService {
  static const String baseUrl = "http://10.0.2.2:8000/api/users/admin/stats/";

  static Future<Map<String, dynamic>> fetchStats() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse(baseUrl),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    return {};
  }
}
