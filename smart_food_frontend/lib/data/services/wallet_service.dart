import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/services/api_client.dart';

class WalletService {
  static const String baseUrl = "http://10.0.2.2:8000/api/payments/wallet";

  static Future<Map<String, dynamic>> fetch(String role, {String? range}) async {
    final query = range != null ? "?range=$range" : "";
    final res = await ApiClient.send(
      (token) => http.get(
        Uri.parse("$baseUrl/$role/$query"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );

    if (res.statusCode == 200) {
      return json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    return {"wallet": {"balance": 0}, "transactions": []};
  }

  static Future<Map<String, dynamic>?> action(
      String role, String action, double amount,
      {String? note}) async {
    final res = await ApiClient.send(
      (token) => http.post(
        Uri.parse("$baseUrl/$role/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "action": action,
          "amount": amount,
          "note": note,
        }),
      ),
    );

    if (res.statusCode == 200) {
      return json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    return null;
  }
}
