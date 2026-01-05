import 'package:flutter/foundation.dart';
import 'package:smart_food_frontend/data/services/shipper_service.dart';

class ShipperProvider with ChangeNotifier {
  bool _loading = false;
  bool _registered = false;
  Map<String, dynamic>? _me;
  bool _loadingMe = false;
  bool _adminLoading = false;
  List<Map<String, dynamic>> _adminShippers = [];

  bool get loading => _loading;
  bool get registered => _registered;
  Map<String, dynamic>? get me => _me;
  bool get loadingMe => _loadingMe;
  bool get adminLoading => _adminLoading;
  List<Map<String, dynamic>> get adminShippers => _adminShippers;

  Future<bool> register(Map<String, dynamic> payload) async {
    _loading = true;
    notifyListeners();
    final ok = await ShipperService.register(payload);
    _registered = ok;
    _loading = false;
    notifyListeners();
    return ok;
  }

  Future<Map<String, dynamic>?> fetchMe() async {
    _loadingMe = true;
    notifyListeners();
    final data = await ShipperService.me();
    _me = data;
    _loadingMe = false;
    notifyListeners();
    return data;
  }

  Future<Map<String, dynamic>?> toggleStatus(bool online) async {
    _loadingMe = true;
    notifyListeners();
    final data = await ShipperService.toggleStatus(online);
    if (data != null) {
      _me = data;
    }
    _loadingMe = false;
    notifyListeners();
    return data;
  }

  Future<Map<String, dynamic>?> updateLocation(double latitude, double longitude) async {
    final data = await ShipperService.updateLocation(latitude, longitude);
    if (data != null) {
      _me = data;
      notifyListeners();
    }
    return data;
  }

  Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> body) async {
    _loadingMe = true;
    notifyListeners();
    final data = await ShipperService.updateProfile(body);
    if (data != null) {
      _me = data;
    }
    _loadingMe = false;
    notifyListeners();
    return data;
  }

  // ============================
  // Admin
  // ============================
  Future<void> loadAdminShippers({int? status}) async {
    _adminLoading = true;
    notifyListeners();
    _adminShippers = await ShipperService.adminList(status: status);
    _adminLoading = false;
    notifyListeners();
  }

  Future<bool> approveShipper(int id) async {
    final ok = await ShipperService.approve(id);
    if (ok) {
      await loadAdminShippers(status: 1);
    }
    return ok;
  }

  Future<bool> rejectShipper(int id) async {
    final ok = await ShipperService.reject(id);
    if (ok) {
      await loadAdminShippers(status: 1);
    }
    return ok;
  }

  Future<bool> banShipper(int id, {bool ban = true}) async {
    final ok = await ShipperService.ban(id, ban: ban);
    if (ok) {
      await loadAdminShippers(); // reload all
    }
    return ok;
  }
}
