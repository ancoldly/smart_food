import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/services/api_client.dart';

class ReviewService {
  static const String baseUrl = "http://10.0.2.2:8000/api/orders/reviews/";

  static Future<List<Map<String, dynamic>>> fetchByOrder(int orderId) =>
      _fetch(params: {"order": orderId});

  static Future<List<Map<String, dynamic>>> fetchByStore(
    int storeId, {
    int? limit,
  }) =>
      _fetch(
        params: {
          "store": storeId,
          if (limit != null) "limit": limit,
        },
      );

  static Future<List<Map<String, dynamic>>> fetchByProduct(
    int productId, {
    int? limit,
  }) =>
      _fetch(
        params: {
          "product": productId,
          if (limit != null) "limit": limit,
        },
      );

  static Future<bool> submit({
    required int orderId,
    required int storeRating,
    String? storeComment,
    required List<Map<String, dynamic>> productReviews,
  }) async {
    final body = {
      "order_id": orderId,
      "store_rating": storeRating,
      "store_comment": storeComment,
      "product_reviews": productReviews,
    };
    final res = await ApiClient.send(
      (token) => http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      ),
    );
    return res.statusCode == 200;
  }

  static Future<List<Map<String, dynamic>>> _fetch({
    required Map<String, dynamic> params,
  }) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: params.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
    final res = await ApiClient.send(
      (token) => http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    if (res.statusCode == 200) {
      final decoded = json.decode(utf8.decode(res.bodyBytes)) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }
}
