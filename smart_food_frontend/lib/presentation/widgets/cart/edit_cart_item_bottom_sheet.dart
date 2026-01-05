import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/cart_item_model.dart';
import 'package:smart_food_frontend/data/models/option_model.dart';
import 'package:smart_food_frontend/presentation/widgets/cart/add_to_cart_bottom_sheet.dart'
    as add_sheet;

Future<void> showEditCartItemBottomSheet(
  BuildContext context,
  CartItemModel item,
) async {
  final presetSelections = <int, List<OptionModel>>{};
  for (final sel in item.selections) {
    presetSelections.putIfAbsent(sel.optionGroupId, () => []);
    presetSelections[sel.optionGroupId]!.add(sel.option);
  }

  await add_sheet.showAddToCartBottomSheet(
    context,
    item.product,
    presetQuantity: item.quantity,
    presetSelections: presetSelections,
    cartItemId: item.cartItemId,
    isUpdate: true,
  );
}
