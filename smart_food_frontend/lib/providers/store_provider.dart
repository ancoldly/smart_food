import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/services/store_service.dart';

class StoreProvider with ChangeNotifier {
  // Admin: list store
  List<StoreModel> _stores = [];
  List<StoreModel> get stores => _stores;

  // User: only ONE store
  StoreModel? _myStore;
  StoreModel? get myStore => _myStore;

  bool _loading = false;
  bool get loading => _loading;

  // ================================
  // ADMIN — Load all stores
  // ================================
  Future<void> loadStoresAdmin() async {
    _loading = true;
    notifyListeners();

    _stores = await StoreService.fetchStoresAdmin();

    _loading = false;
    notifyListeners();
  }

  // ================================
  // USER — Load 1 store
  // ================================
  Future<void> loadMyStore() async {
    _loading = true;
    notifyListeners();

    _myStore = await StoreService.fetchMyStore();

    _loading = false;
    notifyListeners();
  }

  // ================================
  // CREATE STORE
  // ================================
  Future<bool> addStore({
    required Map<String, String> fields,
    File? backgroundImage,
  }) async {
    final success = await StoreService.createStore(
      fields: fields,
      backgroundImage: backgroundImage,
    );

    if (success) {
      await loadMyStore(); // user luôn chỉ có 1 store
    }

    return success;
  }

  // ================================
  // UPDATE STORE
  // ================================
  Future<bool> updateStore({
    required int id,
    required Map<String, String> fields,
    File? backgroundImage,
  }) async {
    final success = await StoreService.updateStore(
      id: id,
      fields: fields,
      backgroundImage: backgroundImage,
    );

    if (success) {
      await loadMyStore();
    }

    return success;
  }

  // ================================
  // DELETE (USER)
  // ================================
  Future<bool> deleteStore(int id) async {
    final success = await StoreService.deleteStore(id);

    if (success) {
      _myStore = null;
      notifyListeners();
    }

    return success;
  }

  // ================================
  // USER — Toggle store (open/close)
  // ================================
  Future<bool> toggleStore(int id) async {
    final success = await StoreService.toggleStore(id);

    if (success) {
      await loadMyStore(); // cập nhật lại trạng thái mới
    }

    return success;
  }

  // ================================
  // ADMIN — Approve/Reject
  // ================================
  Future<bool> approveStore(int id) async {
    final success = await StoreService.approveStore(id);

    if (success) {
      await loadStoresAdmin();
    }

    return success;
  }

  Future<bool> rejectStore(int id) async {
    final success = await StoreService.rejectStore(id);

    if (success) {
      await loadStoresAdmin();
    }

    return success;
  }
}
