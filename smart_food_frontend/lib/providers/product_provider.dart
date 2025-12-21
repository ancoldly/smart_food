import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/data/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  ProductModel? _selectedProduct;
  bool _loading = false;

  List<ProductModel> get products => _products;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get loading => _loading;

  Future<void> loadProducts() async {
    _loading = true;
    notifyListeners();
    _products = await ProductService.fetchProducts();
    _loading = false;
    notifyListeners();
  }

  Future<void> loadProduct(int id) async {
    _selectedProduct = await ProductService.fetchProduct(id);
    notifyListeners();
  }

  Future<bool> addProduct({
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    final ok = await ProductService.createProduct(
      fields: fields,
      imageFile: imageFile,
    );
    if (ok) {
      await loadProducts();
    }
    return ok;
  }

  Future<bool> updateProduct({
    required int id,
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    final ok = await ProductService.updateProduct(
      id: id,
      fields: fields,
      imageFile: imageFile,
    );
    if (ok) {
      await loadProducts();
    }
    return ok;
  }

  Future<bool> deleteProduct(int id) async {
    final ok = await ProductService.deleteProduct(id);
    if (ok) {
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    }
    return ok;
  }
}
