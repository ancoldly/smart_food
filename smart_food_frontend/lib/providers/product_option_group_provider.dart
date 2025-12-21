import 'package:flutter/foundation.dart';

import 'package:smart_food_frontend/data/models/product_option_group_model.dart';
import 'package:smart_food_frontend/data/services/product_option_group_service.dart';

class ProductOptionGroupProvider with ChangeNotifier {
  List<ProductOptionGroupModel> _links = [];
  bool _loading = false;

  List<ProductOptionGroupModel> get links => _links;
  bool get loading => _loading;

  Future<void> loadLinks() async {
    _loading = true;
    notifyListeners();
    _links = await ProductOptionGroupService.fetchLinks();
    _loading = false;
    notifyListeners();
  }

  Future<bool> addLink(Map<String, dynamic> body) async {
    final ok = await ProductOptionGroupService.createLink(body);
    if (ok) await loadLinks();
    return ok;
  }

  Future<bool> updateLink(int id, Map<String, dynamic> body) async {
    final ok = await ProductOptionGroupService.updateLink(id, body);
    if (ok) await loadLinks();
    return ok;
  }

  Future<bool> deleteLink(int id) async {
    final ok = await ProductOptionGroupService.deleteLink(id);
    if (ok) {
      _links.removeWhere((l) => l.id == id);
      notifyListeners();
    }
    return ok;
  }
}
