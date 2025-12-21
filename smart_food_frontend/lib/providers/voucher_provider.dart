import 'package:flutter/foundation.dart';

import 'package:smart_food_frontend/data/models/voucher_model.dart';
import 'package:smart_food_frontend/data/services/voucher_service.dart';

class VoucherProvider with ChangeNotifier {
  List<VoucherModel> _publicVouchers = [];
  List<VoucherModel> _adminVouchers = [];
  bool _loading = false;

  List<VoucherModel> get publicVouchers => _publicVouchers;
  List<VoucherModel> get adminVouchers => _adminVouchers;
  bool get loading => _loading;

  Future<void> loadPublic() async {
    _loading = true;
    notifyListeners();
    _publicVouchers = await VoucherService.fetchPublic();
    _loading = false;
    notifyListeners();
  }

  Future<void> loadAdmin() async {
    _loading = true;
    notifyListeners();
    _adminVouchers = await VoucherService.fetchAdmin();
    _loading = false;
    notifyListeners();
  }

  Future<bool> createAdmin(Map<String, dynamic> body) async {
    final ok = await VoucherService.createAdmin(body);
    if (ok) await loadAdmin();
    return ok;
  }

  Future<bool> updateAdmin(int id, Map<String, dynamic> body) async {
    final ok = await VoucherService.updateAdmin(id, body);
    if (ok) await loadAdmin();
    return ok;
  }

  Future<bool> deleteAdmin(int id) async {
    final ok = await VoucherService.deleteAdmin(id);
    if (ok) {
      _adminVouchers.removeWhere((v) => v.id == id);
      notifyListeners();
    }
    return ok;
  }
}
