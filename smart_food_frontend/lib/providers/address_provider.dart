import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/address_model.dart';
import 'package:smart_food_frontend/data/services/address_service.dart';

class AddressProvider with ChangeNotifier {
  List<AddressModel> _addresses = [];
  List<AddressModel> get addresses => _addresses;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> loadAddresses() async {
    _loading = true;
    notifyListeners();

    _addresses = await AddressService.fetchAddresses();

    _loading = false;
    notifyListeners();
  }

  Future<bool> addAddress(Map<String, dynamic> body) async {
    final success = await AddressService.createAddress(body);

    if (success) {
      await loadAddresses();
    }

    return success;
  }

  Future<bool> updateAddress(int id, Map<String, dynamic> body) async {
    final success = await AddressService.updateAddress(id, body);

    if (success) {
      await loadAddresses();
    }

    return success;
  }

  Future<bool> deleteAddress(int id) async {
    final success = await AddressService.deleteAddress(id);

    if (success) {
      await loadAddresses();
    }

    return success;
  }

  Future<bool> setDefault(int id) async {
    final success = await AddressService.setDefault(id);

    if (success) {
      await loadAddresses();
    }

    return success;
  }
}
