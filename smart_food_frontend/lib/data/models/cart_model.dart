import 'package:smart_food_frontend/data/models/cart_item_model.dart';
import 'package:smart_food_frontend/data/models/option_model.dart';
import 'package:smart_food_frontend/data/models/product_model.dart';

class CartModel {
  final int id;
  final int storeId;
  final List<CartItemModel> items;
  final double total;

  CartModel({
    required this.id,
    required this.storeId,
    required this.items,
    required this.total,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    final List<CartItemModel> parsedItems = [];
    for (final item in (json["items"] as List<dynamic>? ?? [])) {
      final productJson = item["product"] as Map<String, dynamic>? ?? {};
      final product = ProductModel.fromJson(productJson);

      // parse options (option or option_template)
      final selections = <CartOptionSelection>[];
      for (final opt in (item["options"] as List<dynamic>? ?? [])) {
        final optMap = opt as Map<String, dynamic>;
        final optId = optMap["option"];
        final optTplId = optMap["option_template"];
        final optionName = optMap["name"] ?? "";
        final optionPrice = _toDouble(optMap["price"]);
        final ogId = optMap["option_group_id"];
        final ogTplId = optMap["option_group_template_id"];

        final optionGroupId = ogId != null
            ? _toInt(ogId)
            : ogTplId != null
                ? -_toInt(ogTplId)
                : 0;

        final optionModel = OptionModel(
          id: optTplId ?? optId ?? 0,
          optionGroupId: optionGroupId,
          name: optionName,
          price: optionPrice,
          position: 0,
          createdAt: "",
          updatedAt: "",
        );

        selections.add(
          CartOptionSelection(
            optionGroupId: optionGroupId,
            option: optionModel,
          ),
        );
      }

      parsedItems.add(
        CartItemModel(
          cartItemId: item["id"],
          product: product,
          quantity: _toInt(item["quantity"]) == 0 ? 1 : _toInt(item["quantity"]),
          selections: selections,
        ),
      );
    }

    return CartModel(
      id: json["id"],
      storeId: json["store"],
      items: parsedItems,
      total: _toDouble(json["total"]),
    );
  }
}
