import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/services/wallet_service.dart';
import 'package:smart_food_frontend/data/services/earnings_service.dart';

class EarningsProvider with ChangeNotifier {
  double merchantTotal = 0;
  int merchantOrderCount = 0;
  double shipperTotal = 0;
  int shipperCount = 0;
  final List<Map<String, dynamic>> merchantTransactions = [];
  final List<Map<String, dynamic>> shipperTransactions = [];
  bool loadingMerchant = false;
  bool loadingShipper = false;

  Future<void> fetchMerchant({String? range}) async {
    loadingMerchant = true;
    notifyListeners();
    final data = await WalletService.fetch("merchant", range: range);
    _syncFromWallet("merchant", data);
    try {
      final earnings = await EarningsService.merchant();
      merchantOrderCount = earnings["count"] ?? merchantOrderCount;
    } catch (_) {}
    loadingMerchant = false;
    notifyListeners();
  }

  Future<void> fetchShipper({String? range}) async {
    loadingShipper = true;
    notifyListeners();
    final data = await WalletService.fetch("shipper", range: range);
    _syncFromWallet("shipper", data);
    try {
      final earnings = await EarningsService.shipper();
      shipperCount = earnings["count"] ?? shipperCount;
    } catch (_) {}
    loadingShipper = false;
    notifyListeners();
  }

  Future<bool> topupMerchant(double amount, {String? note}) async {
    final data = await WalletService.action("merchant", "topup", amount, note: note);
    if (data == null) return false;
    _syncFromWallet("merchant", data);
    notifyListeners();
    return true;
  }

  Future<bool> withdrawMerchant(double amount, {String? note}) async {
    final data = await WalletService.action("merchant", "withdraw", amount, note: note);
    if (data == null) return false;
    _syncFromWallet("merchant", data);
    notifyListeners();
    return true;
  }

  Future<bool> topupShipper(double amount, {String? note}) async {
    final data = await WalletService.action("shipper", "topup", amount, note: note);
    if (data == null) return false;
    _syncFromWallet("shipper", data);
    notifyListeners();
    return true;
  }

  Future<bool> withdrawShipper(double amount, {String? note}) async {
    final data = await WalletService.action("shipper", "withdraw", amount, note: note);
    if (data == null) return false;
    _syncFromWallet("shipper", data);
    notifyListeners();
    return true;
  }

  void _syncFromWallet(String role, Map<String, dynamic> data) {
    final wallet = data["wallet"] as Map<String, dynamic>? ?? {};
    final txList = (data["transactions"] as List<dynamic>? ?? []);
    final parsedTx = _parseTransactions(txList);
    if (role == "merchant") {
      merchantTotal = _toDouble(wallet["balance"]);
      merchantTransactions
        ..clear()
        ..addAll(parsedTx);
    } else {
      shipperTotal = _toDouble(wallet["balance"]);
      shipperCount = txList.length;
      shipperTransactions
        ..clear()
        ..addAll(parsedTx);
    }
  }

  List<Map<String, dynamic>> _parseTransactions(List<dynamic> txList) {
    return txList.map((item) {
      final map = item as Map<String, dynamic>;
      final amount = _toDouble(map["amount"]);
      final created = DateTime.tryParse(map["created_at"]?.toString() ?? "");
      return {
        "amount": amount,
        "note": map["note"]?.toString() ?? "",
        "type": map["type"]?.toString() ?? "",
        "created_at": created,
      };
    }).toList();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
