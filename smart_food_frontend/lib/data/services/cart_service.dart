import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/cart_item_model.dart';
import 'package:smart_food_frontend/data/models/cart_model.dart';
import 'package:smart_food_frontend/data/models/draft_cart_model.dart';
import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class CartService {
  static const String baseUrl = "http://10.0.2.2:8000/api/cart";

  static Future<CartModel?> fetchCart(int storeId) async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/?store=$storeId"),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return CartModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<CartModel?> addItem({
    required ProductModel product,
    required int quantity,
    required List<CartOptionSelection> selections,
  }) async {
    final options = selections
        .map((s) => s.optionGroupId < 0
            ? {
                "option_template_id": s.option.id,
              }
            : {
                "option_id": s.option.id,
              })
        .toList();

    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/add-item/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "store_id": product.storeId,
          "product_id": product.id,
          "quantity": quantity,
          "options": options,
        }),
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return CartModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<CartModel?> updateItem({
    required int itemId,
    required int quantity,
  }) async {
    final res = await ApiClient.send((token) {
      return http.patch(
        Uri.parse("$baseUrl/items/$itemId/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"quantity": quantity}),
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return CartModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<CartModel?> deleteItem({
    required int itemId,
  }) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/items/$itemId/delete/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return CartModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<List<DraftCartModel>> fetchDraftCarts() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/drafts/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => DraftCartModel.fromJson(e)).toList();
    }
    return [];
  }
}
