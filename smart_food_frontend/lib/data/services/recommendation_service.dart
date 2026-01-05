import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class RecommendationItem {
  final ProductModel product;
  final double score;
  final String? reason;

  RecommendationItem({
    required this.product,
    required this.score,
    this.reason,
  });
}

class RecommendationService {
  static const String baseUrl = "http://10.0.2.2:8000/api/recommendations";
  static Future<void> logEvent({
    int? productId,
    int? storeId,
    required String event,
    int quantity = 1,
    double? value,
    Map<String, dynamic>? meta,
  }) async {
    if (productId == null && storeId == null) return;
    try {
      await ApiClient.send((token) {
        return http.post(
          Uri.parse("$baseUrl/events/"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "product_id": productId,
            "store_id": storeId,
            "event": event,
            "quantity": quantity,
            if (value != null) "value": value,
            if (meta != null) "meta": meta,
          }),
        );
      });
    } catch (_) {
      // bỏ qua lỗi log để không ảnh hưởng UI
    }
  }

  static Future<List<RecommendationItem>> fetchFeed({int limit = 20}) async {
    try {
      final res = await ApiClient.send((token) {
        return http.get(
          Uri.parse("$baseUrl/feed/?limit=$limit"),
          headers: {"Authorization": "Bearer $token"},
        );
      });
      if (res.statusCode != 200) return [];
      final decoded = utf8.decode(res.bodyBytes);
      final data = jsonDecode(decoded) as Map<String, dynamic>;
      final List items = data["items"] ?? [];
      return items
          .map((e) => RecommendationItem(
                product: ProductModel.fromJson(e["product"]),
                score: (e["score"] ?? 0).toDouble(),
                reason: e["reason"],
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<RecommendationItem>> fetchSimilar({
    required int productId,
    int limit = 10,
  }) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/similar/?product_id=$productId&limit=$limit"),
      );
      if (res.statusCode != 200) return [];
      final decoded = utf8.decode(res.bodyBytes);
      final data = jsonDecode(decoded) as Map<String, dynamic>;
      final List items = data["items"] ?? [];
      return items
          .map((e) => RecommendationItem(
                product: ProductModel.fromJson(
                  e["similar_product"] ?? e["product"],
                ),
                score: (e["score"] ?? 0).toDouble(),
                reason: e["reason"],
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
