import 'package:flutter/foundation.dart';

import 'package:smart_food_frontend/data/models/option_template_model.dart';
import 'package:smart_food_frontend/data/services/option_template_service.dart';

class OptionTemplateProvider with ChangeNotifier {
  List<OptionTemplateModel> _options = [];
  OptionTemplateModel? _selected;
  bool _loading = false;

  List<OptionTemplateModel> get options => _options;
  OptionTemplateModel? get selected => _selected;
  bool get loading => _loading;

  Future<void> loadOptions() async {
    _loading = true;
    notifyListeners();
    _options = await OptionTemplateService.fetchOptions();
    _loading = false;
    notifyListeners();
  }

  Future<bool> addOption(Map<String, dynamic> body) async {
    final ok = await OptionTemplateService.createOption(body);
    if (ok) await loadOptions();
    return ok;
  }

  Future<bool> updateOption(int id, Map<String, dynamic> body) async {
    final ok = await OptionTemplateService.updateOption(id, body);
    if (ok) await loadOptions();
    return ok;
  }

  Future<bool> deleteOption(int id) async {
    final ok = await OptionTemplateService.deleteOption(id);
    if (ok) {
      _options.removeWhere((o) => o.id == id);
      notifyListeners();
    }
    return ok;
  }
}
