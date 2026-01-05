import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/order_model.dart';
import 'package:smart_food_frontend/data/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _loading = false;
  bool get loading => _loading;
  List<OrderModel> get orders => _orders;
  bool reorderLoading = false;

  Future<void> loadOrders() async {
    _loading = true;
    notifyListeners();
    _orders = await OrderService.fetchOrders();
    _loading = false;
    notifyListeners();
  }

  Future<OrderModel?> createOrder(Map<String, dynamic> body) async {
    final order = await OrderService.createOrder(body);
    if (order != null) {
      _orders.insert(0, order);
      notifyListeners();
    }
    return order;
  }

  Future<bool> reorder(int orderId) async {
    reorderLoading = true;
    notifyListeners();
    final ok = await OrderService.reorder(orderId);
    reorderLoading = false;
    notifyListeners();
    return ok;
  }
}
