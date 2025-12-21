import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/voucher_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class VoucherService {
  static const String baseUrl = "http://10.0.2.2:8000/api/vouchers";

  // PUBLIC: list voucher đang hoạt động
  static Future<List<VoucherModel>> fetchPublic() async {
    final res = await http.get(Uri.parse("$baseUrl/public/"));
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => VoucherModel.fromJson(e)).toList();
    }
    return [];
  }

  // ADMIN: list
  static Future<List<VoucherModel>> fetchAdmin() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/admin/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => VoucherModel.fromJson(e)).toList();
    }
    return [];
  }

  // ADMIN: create
  static Future<bool> createAdmin(Map<String, dynamic> body) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/admin/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    });
    return res.statusCode == 201;
  }

  // ADMIN: update (partial)
  static Future<bool> updateAdmin(int id, Map<String, dynamic> body) async {
    final res = await ApiClient.send((token) {
      return http.patch(
        Uri.parse("$baseUrl/admin/$id/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    });
    return res.statusCode == 200;
  }

  // ADMIN: delete
  static Future<bool> deleteAdmin(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/admin/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    return res.statusCode == 204;
  }
}
