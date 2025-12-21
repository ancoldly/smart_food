import 'package:flutter/foundation.dart';
import 'package:smart_food_frontend/data/models/category_model.dart';
import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/data/services/category_service.dart';
import 'package:smart_food_frontend/data/services/product_service.dart';

class StoreMenuProvider with ChangeNotifier {
  final Map<int, List<CategoryModel>> _categoriesByStore = {};
  final Map<int, List<ProductModel>> _productsByStore = {};
  final Set<int> _loadingStoreIds = {};

  List<CategoryModel> categoriesFor(int storeId) =>
      _categoriesByStore[storeId] ?? [];

  List<ProductModel> productsFor(int storeId) =>
      _productsByStore[storeId] ?? [];

  bool isLoading(int storeId) => _loadingStoreIds.contains(storeId);

  Future<void> loadMenu(int storeId) async {
    _loadingStoreIds.add(storeId);
    notifyListeners();
    final categories = await CategoryService.fetchCategoriesByStore(storeId);
    final products = await ProductService.fetchProductsByStore(storeId: storeId);
    _categoriesByStore[storeId] = categories;
    _productsByStore[storeId] = products;
    _loadingStoreIds.remove(storeId);
    notifyListeners();
  }
}
