import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/services/api_client.dart';

class FavoriteService {
  static const String baseUrl = "http://10.0.2.2:8000/api/stores/favorites/";

  static Future<List<int>> fetchFavoriteStoreIds() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse(baseUrl),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final data = jsonDecode(decoded);
      final List ids = data["store_ids"] ?? [];
      return ids.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    }
    return [];
  }

  static Future<bool?> toggleFavorite(int storeId) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse(baseUrl),
        headers: {"Authorization": "Bearer $token"},
        body: {"store_id": storeId.toString()},
      );
    });
    if (res.statusCode == 200 || res.statusCode == 201) {
      final decoded = utf8.decode(res.bodyBytes);
      final data = jsonDecode(decoded);
      return data["is_favorite"] as bool?;
    }
    return null;
  }
}
