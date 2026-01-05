import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/order_model.dart';
import 'package:smart_food_frontend/data/services/shipper_order_service.dart';

class ShipperOrderProvider with ChangeNotifier {
  List<OrderModel> _assigned = [];
  List<OrderModel> _available = [];
  bool _loading = false;

  List<OrderModel> get assigned => _assigned;
  List<OrderModel> get available => _available;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _assigned = await ShipperOrderService.fetchAssigned();
    _available = await ShipperOrderService.fetchAvailable();
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() => load();

  Future<void> accept(int id) async {
    final order = await ShipperOrderService.accept(id);
    if (order != null) {
      _assigned.insert(0, order);
      _available.removeWhere((o) => o.id == id);
      notifyListeners();
    }
  }

  Future<void> complete(int id) async {
    final updated = await ShipperOrderService.complete(id);
    if (updated != null) {
      _assigned = _assigned.map((o) => o.id == id ? updated : o).toList();
      notifyListeners();
    }
  }
}
