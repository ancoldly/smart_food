import 'package:flutter/foundation.dart';

import 'package:smart_food_frontend/data/models/option_model.dart';
import 'package:smart_food_frontend/data/services/option_service.dart';

class OptionProvider with ChangeNotifier {
  List<OptionModel> _options = [];
  OptionModel? _selectedOption;
  bool _loading = false;

  List<OptionModel> get options => _options;
  OptionModel? get selectedOption => _selectedOption;
  bool get loading => _loading;

  Future<void> loadOptions() async {
    _loading = true;
    notifyListeners();
    _options = await OptionService.fetchOptions();
    _loading = false;
    notifyListeners();
  }

  Future<void> loadOption(int id) async {
    _selectedOption = await OptionService.fetchOption(id);
    notifyListeners();
  }

  Future<bool> addOption(Map<String, dynamic> body) async {
    final ok = await OptionService.createOption(body);
    if (ok) {
      await loadOptions();
    }
    return ok;
  }

  Future<bool> updateOption(int id, Map<String, dynamic> body) async {
    final ok = await OptionService.updateOption(id, body);
    if (ok) {
      await loadOptions();
    }
    return ok;
  }

  Future<bool> deleteOption(int id) async {
    final ok = await OptionService.deleteOption(id);
    if (ok) {
      _options.removeWhere((o) => o.id == id);
      notifyListeners();
    }
    return ok;
  }
}
