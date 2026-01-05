import 'package:flutter/foundation.dart';

import 'package:smart_food_frontend/data/models/cart_item_model.dart';
import 'package:smart_food_frontend/data/models/cart_model.dart';
import 'package:smart_food_frontend/data/models/draft_cart_model.dart';
import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/data/services/cart_service.dart';
import 'package:smart_food_frontend/data/services/recommendation_service.dart';

class CartProvider with ChangeNotifier {
  final Map<int, CartModel> _cartsByStore = {}; // storeId -> cart
  final Set<int> _loadingStoreIds = {};
  List<DraftCartModel> _drafts = [];
  bool _loadingDrafts = false;

  CartModel? cartFor(int storeId) => _cartsByStore[storeId];
  bool isLoading(int storeId) => _loadingStoreIds.contains(storeId);
  List<DraftCartModel> get drafts => _drafts;
  bool get loadingDrafts => _loadingDrafts;

  Future<void> loadCart(int storeId) async {
    _loadingStoreIds.add(storeId);
    notifyListeners();
    final cart = await CartService.fetchCart(storeId);
    if (cart != null) {
      _cartsByStore[storeId] = cart;
    } else {
      _cartsByStore.remove(storeId);
    }
    _loadingStoreIds.remove(storeId);
    notifyListeners();
  }

  Future<bool> addItem(
    ProductModel product,
    int quantity,
    List<CartOptionSelection> selections,
  ) async {
    final cart = await CartService.addItem(
      product: product,
      quantity: quantity,
      selections: selections,
    );
    if (cart != null) {
      _cartsByStore[cart.storeId] = cart;
      notifyListeners();
      await loadDraftCarts(silent: true);
      RecommendationService.logEvent(
        productId: product.id,
        storeId: product.storeId,
        event: "add_to_cart",
        quantity: quantity,
      );
      return true;
    }
    return false;
  }

  Future<bool> updateItemQuantity({
    required int storeId,
    required int itemId,
    required int quantity,
  }) async {
    final cart = await CartService.updateItem(
      itemId: itemId,
      quantity: quantity,
    );
    if (cart != null) {
      _cartsByStore[cart.storeId] = cart;
      notifyListeners();
      await loadDraftCarts(silent: true);
      return true;
    }
    return false;
  }

  Future<bool> removeItem({
    required int storeId,
    required int itemId,
  }) async {
    final cart = await CartService.deleteItem(itemId: itemId);
    if (cart != null) {
      _cartsByStore[cart.storeId] = cart;
      notifyListeners();
      await loadDraftCarts(silent: true);
      return true;
    }
    return false;
  }

  double totalFor(int storeId) => _cartsByStore[storeId]?.total ?? 0;
  List<CartItemModel> itemsFor(int storeId) =>
      _cartsByStore[storeId]?.items ?? [];

  int itemCountFor(int storeId) =>
      _cartsByStore[storeId]?.items.length ?? 0;

  Future<void> loadDraftCarts({bool silent = false}) async {
    if (!silent) {
      _loadingDrafts = true;
      notifyListeners();
    }
    _drafts = await CartService.fetchDraftCarts();
    if (!silent) {
      _loadingDrafts = false;
    }
    notifyListeners();
  }
}
