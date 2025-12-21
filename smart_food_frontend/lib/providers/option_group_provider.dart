import 'package:flutter/foundation.dart';

import 'package:smart_food_frontend/data/models/option_group_model.dart';
import 'package:smart_food_frontend/data/services/option_group_service.dart';

class OptionGroupProvider with ChangeNotifier {
  List<OptionGroupModel> _groups = [];
  OptionGroupModel? _selectedGroup;
  bool _loading = false;

  List<OptionGroupModel> get groups => _groups;
  OptionGroupModel? get selectedGroup => _selectedGroup;
  bool get loading => _loading;

  Future<void> loadGroups() async {
    _loading = true;
    notifyListeners();
    _groups = await OptionGroupService.fetchOptionGroups();
    _loading = false;
    notifyListeners();
  }

  Future<void> loadGroup(int id) async {
    _selectedGroup = await OptionGroupService.fetchOptionGroup(id);
    notifyListeners();
  }

  Future<bool> addGroup(Map<String, dynamic> body) async {
    final ok = await OptionGroupService.createOptionGroup(body);
    if (ok) {
      await loadGroups();
    }
    return ok;
  }

  Future<bool> updateGroup(int id, Map<String, dynamic> body) async {
    final ok = await OptionGroupService.updateOptionGroup(id, body);
    if (ok) {
      await loadGroups();
    }
    return ok;
  }

  Future<bool> deleteGroup(int id) async {
    final ok = await OptionGroupService.deleteOptionGroup(id);
    if (ok) {
      _groups.removeWhere((g) => g.id == id);
      notifyListeners();
    }
    return ok;
  }
}
