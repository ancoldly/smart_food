import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/services/merchant_review_service.dart';

class MerchantReviewProvider with ChangeNotifier {
  bool loading = false;
  List<Map<String, dynamic>> items = [];
  Map<String, dynamic> summary = {};

  Future<void> fetch({int? productId}) async {
    loading = true;
    notifyListeners();
    final data = await MerchantReviewService.fetch(productId: productId);
    items = (data["items"] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
    summary = data["summary"] as Map<String, dynamic>? ?? {};
    loading = false;
    notifyListeners();
  }

  Future<bool> reply(int reviewId, String reply) async {
    final ok = await MerchantReviewService.reply(reviewId, reply);
    if (ok) {
      final idx = items.indexWhere((e) => e["id"] == reviewId);
      if (idx != -1) {
        items[idx]["reply_comment"] = reply;
      }
      notifyListeners();
    }
    return ok;
  }
}
