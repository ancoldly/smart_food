import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/services/api_client.dart';

class ShipperService {
  static const String baseUrl = "http://10.0.2.2:8000/api/shippers";

  static Future<bool> register(Map<String, dynamic> payload) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/register/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );
    });
    return res.statusCode == 201;
  }

  static Future<Map<String, dynamic>?> me() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/me/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes));
    }
    return null;
  }

  // ============================
  // Admin
  // ============================
  static Future<List<Map<String, dynamic>>> adminList({int? status}) async {
    final uri = Uri.parse("$baseUrl/admin/")
        .replace(queryParameters: status != null ? {"status": "$status"} : {});
    final res = await ApiClient.send((token) {
      return http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<bool> approve(int id) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/admin/$id/approve/"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
    });
    return res.statusCode == 200;
  }

  static Future<bool> reject(int id) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/admin/$id/reject/"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
    });
    return res.statusCode == 200;
  }

  static Future<bool> ban(int id, {required bool ban}) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/admin/$id/ban/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"ban": ban}),
      );
    });
    return res.statusCode == 200;
  }

  // ============================
  // Shipper self toggle status
  // ============================
  static Future<Map<String, dynamic>?> toggleStatus(bool online) async {
    final res = await ApiClient.send((token) {
      return http.patch(
        Uri.parse("$baseUrl/me/status/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"online": online}),
      );
    });
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateLocation(double latitude, double longitude) async {
    final res = await ApiClient.send((token) {
      return http.patch(
        Uri.parse("$baseUrl/me/location/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"latitude": latitude, "longitude": longitude}),
      );
    });
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> body) async {
    final res = await ApiClient.send((token) {
      return http.patch(
        Uri.parse("$baseUrl/me/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    });
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes));
    }
    return null;
  }
}
