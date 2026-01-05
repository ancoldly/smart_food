import 'package:flutter/foundation.dart';

import 'package:smart_food_frontend/data/models/option_group_model.dart';
import 'package:smart_food_frontend/data/services/product_option_service.dart';

class ProductOptionProvider with ChangeNotifier {
  final Map<int, List<OptionGroupModel>> _byProduct = {};
  final Set<int> _loading = {};

  List<OptionGroupModel> groups(int productId) => _byProduct[productId] ?? [];
  bool isLoading(int productId) => _loading.contains(productId);

  Future<void> load(int productId) async {
    if (_loading.contains(productId)) return;
    _loading.add(productId);
    notifyListeners();
    final data = await ProductOptionService.fetchPublicOptions(productId);
    _byProduct[productId] = data..sort((a, b) => a.position.compareTo(b.position));
    _loading.remove(productId);
    notifyListeners();
  }
}
