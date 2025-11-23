import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/services/store_service.dart';

class StoreProvider with ChangeNotifier {
  List<StoreModel> _stores = [];
  List<StoreModel> get stores => _stores;

  bool _loading = false;
  bool get loading => _loading;

  // =============================
  //   LOAD STORES
  // =============================
  Future<void> loadStores() async {
    _loading = true;
    notifyListeners();

    _stores = await StoreService.fetchStores();

    _loading = false;
    notifyListeners();
  }

  // =============================
  //   CREATE STORE
  // =============================
  Future<bool> addStore({
    required Map<String, String> fields,
    File? backgroundImage,
  }) async {
    final success = await StoreService.createStore(
      fields: fields,
      backgroundImage: backgroundImage,
    );

    if (success) {
      await loadStores();
    }

    return success;
  }

  // =============================
  //   UPDATE STORE
  // =============================
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
      await loadStores();
    }

    return success;
  }

  // =============================
  //   DELETE STORE
  // =============================
  Future<bool> deleteStore(int id) async {
    final success = await StoreService.deleteStore(id);

    if (success) {
      await loadStores();
    }

    return success;
  }

  // =============================
  //   TOGGLE STORE STATUS
  // =============================
  Future<bool> toggleStore(int id) async {
    final success = await StoreService.toggleStore(id);

    if (success) {
      await loadStores();
    }

    return success;
  }

  // =============================
  //   ADMIN APPROVE STORE
  // =============================
  Future<bool> approveStore(int id) async {
    final success = await StoreService.approveStore(id);

    if (success) {
      await loadStores();
    }

    return success;
  }

  // =============================
  //   ADMIN REJECT STORE
  // =============================
  Future<bool> rejectStore(int id) async {
    final success = await StoreService.rejectStore(id);

    if (success) {
      await loadStores();
    }

    return success;
  }
}
