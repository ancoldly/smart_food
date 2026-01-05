import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/services/api_client.dart';

class MerchantReviewService {
  static const base = "http://10.0.2.2:8000/api/orders";

  static Future<Map<String, dynamic>> fetch({int? productId}) async {
    final query = productId != null ? "?product=$productId" : "";
    final res = await ApiClient.send(
      (token) => http.get(
        Uri.parse("$base/reviews/merchant/$query"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    if (res.statusCode == 200) {
      return json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    return {"items": [], "summary": {}};
  }

  static Future<bool> reply(int reviewId, String reply) async {
    final res = await ApiClient.send(
      (token) => http.post(
        Uri.parse("$base/reviews/$reviewId/reply/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({"reply": reply}),
      ),
    );
    return res.statusCode == 200;
  }
}
