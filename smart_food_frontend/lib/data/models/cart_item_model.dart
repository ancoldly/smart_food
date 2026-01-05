import 'package:smart_food_frontend/data/models/option_model.dart';
import 'package:smart_food_frontend/data/models/product_model.dart';

class CartOptionSelection {
  final int optionGroupId;
  final OptionModel option;

  CartOptionSelection({required this.optionGroupId, required this.option});
}

class CartItemModel {
  final int? cartItemId;
  final ProductModel product;
  final int quantity;
  final List<CartOptionSelection> selections;

  CartItemModel({
    this.cartItemId,
    required this.product,
    required this.quantity,
    required this.selections,
  });

  double get optionsTotal =>
      selections.fold(0, (sum, sel) => sum + sel.option.price);

  double get unitPrice =>
      product.discountPrice != null && product.discountPrice! > 0
          ? product.discountPrice!
          : product.price;

  double get lineTotal => (unitPrice + optionsTotal) * quantity;

  CartItemModel copyWith({
    int? cartItemId,
    int? quantity,
    List<CartOptionSelection>? selections,
  }) {
    return CartItemModel(
      cartItemId: cartItemId ?? this.cartItemId,
      product: product,
      quantity: quantity ?? this.quantity,
      selections: selections ?? this.selections,
    );
  }
}
