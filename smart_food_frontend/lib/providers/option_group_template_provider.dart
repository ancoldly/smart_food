import 'package:flutter/foundation.dart';

import 'package:smart_food_frontend/data/models/option_group_template_model.dart';
import 'package:smart_food_frontend/data/services/option_group_template_service.dart';

class OptionGroupTemplateProvider with ChangeNotifier {
  List<OptionGroupTemplateModel> _groups = [];
  OptionGroupTemplateModel? _selected;
  bool _loading = false;

  List<OptionGroupTemplateModel> get groups => _groups;
  OptionGroupTemplateModel? get selected => _selected;
  bool get loading => _loading;

  Future<void> loadGroups() async {
    _loading = true;
    notifyListeners();
    _groups = await OptionGroupTemplateService.fetchGroups();
    _loading = false;
    notifyListeners();
  }

  Future<void> loadGroup(int id) async {
    _selected = await OptionGroupTemplateService.fetchGroup(id);
    notifyListeners();
  }

  Future<bool> addGroup(Map<String, dynamic> body) async {
    final ok = await OptionGroupTemplateService.createGroup(body);
    if (ok) await loadGroups();
    return ok;
  }

  Future<bool> updateGroup(int id, Map<String, dynamic> body) async {
    final ok = await OptionGroupTemplateService.updateGroup(id, body);
    if (ok) await loadGroups();
    return ok;
  }

  Future<bool> deleteGroup(int id) async {
    final ok = await OptionGroupTemplateService.deleteGroup(id);
    if (ok) {
      _groups.removeWhere((g) => g.id == id);
      notifyListeners();
    }
    return ok;
  }
}
