import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/services/api_client.dart';

class EarningsService {
  static Future<Map<String, dynamic>> merchant() async {
    final res = await ApiClient.send(
      (token) => http.get(
        Uri.parse("http://10.0.2.2:8000/api/orders/merchant/earnings/"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    if (res.statusCode == 200) {
      return json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    return {"total": 0, "count": 0};
  }

  static Future<Map<String, dynamic>> shipper() async {
    final res = await ApiClient.send(
      (token) => http.get(
        Uri.parse("http://10.0.2.2:8000/api/orders/shipper/earnings/"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    if (res.statusCode == 200) {
      return json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    return {"total": 0, "count": 0};
  }
}
