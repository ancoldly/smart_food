import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/store_tag_model.dart';
import 'package:smart_food_frontend/data/services/store_tag_service.dart';

class StoreTagProvider extends ChangeNotifier {
  List<StoreTagModel> tags = [];
  bool loading = false;

  Future<void> loadTags() async {
    loading = true;
    notifyListeners();
    tags = await StoreTagService.fetchTags();
    loading = false;
    notifyListeners();
  }

  Future<bool> addTag(String name, {String? slug}) async {
    final res = await StoreTagService.createTag({"name": name, "slug": slug});
    if (res != null) {
      tags.insert(0, res);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateTag(int id, String name, {String? slug}) async {
    final res = await StoreTagService.updateTag(id, {"name": name, "slug": slug});
    if (res != null) {
      final idx = tags.indexWhere((e) => e.id == id);
      if (idx != -1) tags[idx] = res;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteTag(int id) async {
    final ok = await StoreTagService.deleteTag(id);
    if (ok) {
      tags.removeWhere((e) => e.id == id);
      notifyListeners();
    }
    return ok;
  }
}
