import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/models/notification_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class NotificationService {
  static const String baseUrl = "http://10.0.2.2:8000/api/notifications";

  static Future<List<NotificationModel>> fetchAll({bool unreadOnly = false}) async {
    // Luôn lấy đầy đủ thông báo (không lọc unread) để không mất lịch sử
    final url = "$baseUrl/";
    final res = await ApiClient.send(
      (token) => http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = json.decode(decoded) as List;
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<bool> markRead(int id) async {
    final res = await ApiClient.send(
      (token) => http.patch(
        Uri.parse("$baseUrl/$id/read/"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    return res.statusCode == 200;
  }

  static Future<int> unreadCount() async {
    final res = await ApiClient.send(
      (token) => http.get(
        Uri.parse("$baseUrl/?unread=1"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = json.decode(decoded) as List;
      return data.length;
    }
    return 0;
  }
}
