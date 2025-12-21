import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/services/store_service.dart';
import 'package:smart_food_frontend/data/models/store_voucher_model.dart';
import 'package:smart_food_frontend/data/models/store_campaign_model.dart';

class StoreProvider with ChangeNotifier {
  // Admin: list store
  List<StoreModel> _stores = [];
  List<StoreModel> get stores => _stores;

  // User: only ONE store
  StoreModel? _myStore;
  StoreModel? get myStore => _myStore;

  bool _loading = false;
  bool get loading => _loading;

  // Store vouchers
  List<StoreVoucherModel> _storeVouchers = [];
  List<StoreVoucherModel> get storeVouchers => _storeVouchers;
  List<StoreCampaignModel> _campaigns = [];
  List<StoreCampaignModel> get campaigns => _campaigns;

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

  // PUBLIC: Load approved stores
  Future<void> loadStoresPublic() async {
    _loading = true;
    notifyListeners();

    _stores = await StoreService.fetchStoresPublic();

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
    File? avatarImage,
    File? backgroundImage,
  }) async {
    final success = await StoreService.createStore(
      fields: fields,
      avatarImage: avatarImage,
      backgroundImage: backgroundImage,
    );

    if (success) {
      await loadMyStore();
    }

    return success;
  }

  // ================================
  // UPDATE STORE
  // ================================
  Future<bool> updateStore({
    required int id,
    required Map<String, String> fields,
    File? avatarImage,
    File? backgroundImage,
  }) async {
    final success = await StoreService.updateStore(
      id: id,
      fields: fields,
      avatarImage: avatarImage,
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

  // ================================
  // STORE VOUCHERS (merchant)
  // ================================
  Future<void> loadStoreVouchers() async {
    _loading = true;
    notifyListeners();
    _storeVouchers = await StoreService.fetchStoreVouchers();
    _loading = false;
    notifyListeners();
  }

  Future<bool> createStoreVoucher(Map<String, dynamic> payload) async {
    final created = await StoreService.createStoreVoucher(payload);
    if (created != null) {
      _storeVouchers.insert(0, created);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateStoreVoucher(int id, Map<String, dynamic> payload) async {
    final updated = await StoreService.updateStoreVoucher(id, payload);
    if (updated != null) {
      final idx = _storeVouchers.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _storeVouchers[idx] = updated;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> deleteStoreVoucher(int id) async {
    final ok = await StoreService.deleteStoreVoucher(id);
    if (ok) {
      _storeVouchers.removeWhere((e) => e.id == id);
      notifyListeners();
    }
    return ok;
  }

  // ================================
  // STORE CAMPAIGNS (merchant)
  // ================================
  Future<void> loadStoreCampaigns() async {
    _loading = true;
    notifyListeners();
    _campaigns = await StoreService.fetchStoreCampaigns();
    _loading = false;
    notifyListeners();
  }

  Future<bool> createStoreCampaign(Map<String, dynamic> payload) async {
    final created = await StoreService.createStoreCampaign(payload);
    if (created != null) {
      _campaigns.insert(0, created);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateStoreCampaign(int id, Map<String, dynamic> payload) async {
    final updated = await StoreService.updateStoreCampaign(id, payload);
    if (updated != null) {
      final idx = _campaigns.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _campaigns[idx] = updated;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> deleteStoreCampaign(int id) async {
    final ok = await StoreService.deleteStoreCampaign(id);
    if (ok) {
      _campaigns.removeWhere((e) => e.id == id);
      notifyListeners();
    }
    return ok;
  }

  Future<void> trackCampaignImpression(int id) async {
    await StoreService.trackCampaignImpression(id);
  }

  Future<void> trackCampaignClick(int id) async {
    await StoreService.trackCampaignClick(id);
  }
}
