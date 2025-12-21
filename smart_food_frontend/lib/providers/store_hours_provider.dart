import 'package:flutter/foundation.dart';
import 'package:smart_food_frontend/data/models/store_operating_hour_model.dart';
import 'package:smart_food_frontend/data/services/store_service.dart';

class StoreHoursProvider with ChangeNotifier {
  List<StoreOperatingHourModel> _hours = [];
  bool _loading = false;

  List<StoreOperatingHourModel> get hours => _hours;
  bool get loading => _loading;

  Future<void> loadHours() async {
    _loading = true;
    notifyListeners();
    _hours = await StoreService.fetchOperatingHours();
    _loading = false;
    notifyListeners();
  }

  Future<bool> updateHour({
    required int id,
    required bool isClosed,
    String? openTime,
    String? closeTime,
  }) async {
    final success = await StoreService.updateOperatingHour(
      id: id,
      isClosed: isClosed,
      openTime: openTime,
      closeTime: closeTime,
    );
    if (success) {
      await loadHours();
    }
    return success;
  }
}
