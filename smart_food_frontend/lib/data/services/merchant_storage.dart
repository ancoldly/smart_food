import 'package:shared_preferences/shared_preferences.dart';

class MerchantStorage {
  static String _key(int userId) => "merchant_welcome_seen_$userId";

  static Future<bool> isWelcomeSeen(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(userId)) ?? false;
  }

  static Future<void> setWelcomeSeen(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(userId), true);
  }

  static Future<void> resetWelcome(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userId));
  }
}
