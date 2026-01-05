import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/models/order_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class ShipperOrderService {
  static const String baseUrl = "http://10.0.2.2:8000/api/orders/shipper/";

  static Future<List<OrderModel>> fetchAssigned() async {
    final res = await ApiClient.send(
      (token) => http.get(
        Uri.parse(baseUrl),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = json.decode(decoded) as List;
      return data.map((e) => OrderModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<OrderModel>> fetchAvailable() async {
    final res = await ApiClient.send(
      (token) => http.get(
        Uri.parse("${baseUrl}available/"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = json.decode(decoded) as List;
      return data.map((e) => OrderModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<OrderModel?> accept(int id) async {
    final res = await ApiClient.send(
      (token) => http.patch(
        Uri.parse("$baseUrl$id/accept/"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return OrderModel.fromJson(json.decode(decoded));
    }
    return null;
  }

  static Future<OrderModel?> complete(int id) async {
    final res = await ApiClient.send(
      (token) => http.patch(
        Uri.parse("$baseUrl$id/complete/"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return OrderModel.fromJson(json.decode(decoded));
    }
    return null;
  }
}
