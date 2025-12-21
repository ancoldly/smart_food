import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:smart_food_frontend/data/models/category_model.dart';
import 'package:smart_food_frontend/data/services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  List<CategoryModel> _adminCategories = [];
  CategoryModel? _selectedCategory;

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get adminCategories => _adminCategories;
  CategoryModel? get selectedCategory => _selectedCategory;

  bool _loading = false;
  bool get loading => _loading;

  // Merchant: load categories for current store
  Future<void> loadCategories() async {
    _loading = true;
    notifyListeners();

    _categories = await CategoryService.fetchCategories();

    _loading = false;
    notifyListeners();
  }

  // Admin: load all categories
  Future<void> loadCategoriesAdmin() async {
    _loading = true;
    notifyListeners();

    _adminCategories = await CategoryService.fetchCategoriesAdmin();

    _loading = false;
    notifyListeners();
  }

  Future<void> loadCategory(int id) async {
    _selectedCategory = await CategoryService.fetchCategory(id);
    notifyListeners();
  }

  Future<bool> addCategory({
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    final ok = await CategoryService.createCategory(
      fields: fields,
      imageFile: imageFile,
    );

    if (ok) {
      await loadCategories();
    }

    return ok;
  }

  Future<bool> updateCategory({
    required int id,
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    final ok = await CategoryService.updateCategory(
      id: id,
      fields: fields,
      imageFile: imageFile,
    );

    if (ok) {
      await loadCategories();
    }

    return ok;
  }

  Future<bool> deleteCategory(int id) async {
    final ok = await CategoryService.deleteCategory(id);

    if (ok) {
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    }

    return ok;
  }
}
