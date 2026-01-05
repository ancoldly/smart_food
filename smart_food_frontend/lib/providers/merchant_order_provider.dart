import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/order_model.dart';
import 'package:smart_food_frontend/data/services/merchant_order_service.dart';

class MerchantOrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _loading = false;

  List<OrderModel> get orders => _orders;
  bool get loading => _loading;

  Future<void> loadOrders() async {
    _loading = true;
    notifyListeners();
    _orders = await MerchantOrderService.fetchOrders();
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async => loadOrders();

  Future<OrderModel?> updateStatus(int id, {String? status, String? paymentStatus}) async {
    final body = <String, dynamic>{};
    if (status != null) body["status"] = status;
    if (paymentStatus != null) body["payment_status"] = paymentStatus;
    final updated = await MerchantOrderService.updateStatus(id, body);
    if (updated != null) {
      _orders = _orders.map((o) => o.id == id ? updated : o).toList();
      notifyListeners();
    }
    return updated;
  }
}
