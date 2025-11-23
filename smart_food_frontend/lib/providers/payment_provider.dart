import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/payment_model.dart';
import 'package:smart_food_frontend/data/services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  List<PaymentModel> _payments = [];
  List<PaymentModel> get payments => _payments;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> loadPayments() async {
    _loading = true;
    notifyListeners();

    _payments = await PaymentService.fetchPayments();

    _loading = false;
    notifyListeners();
  }

  Future<bool> addPayment({
    required Map<String, String> fields,
    File? bankLogo,
  }) async {
    final success = await PaymentService.createPayment(
      fields: fields,
      bankLogoFile: bankLogo,
    );

    if (success) {
      await loadPayments();
    }

    return success;
  }

  Future<bool> updatePayment(int id, Map<String, dynamic> body) async {
    final success = await PaymentService.updatePayment(id, body);

    if (success) {
      await loadPayments();
    }

    return success;
  }

  Future<bool> deletePayment(int id) async {
    final success = await PaymentService.deletePayment(id);

    if (success) {
      await loadPayments();
    }

    return success;
  }

  Future<bool> setDefault(int id) async {
    final success = await PaymentService.setDefault(id);

    if (success) {
      await loadPayments();
    }

    return success;
  }
}
