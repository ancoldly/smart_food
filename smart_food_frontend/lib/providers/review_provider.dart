import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  bool loading = false;
  bool submitted = false;

  Future<List<dynamic>> fetch(int orderId) async {
    loading = true;
    notifyListeners();
    final data = await ReviewService.fetchByOrder(orderId);
    loading = false;
    notifyListeners();
    return data;
  }

  Future<bool> submit({
    required int orderId,
    required int storeRating,
    String? storeComment,
    required List<Map<String, dynamic>> productReviews,
  }) async {
    loading = true;
    notifyListeners();
    final ok = await ReviewService.submit(
      orderId: orderId,
      storeRating: storeRating,
      storeComment: storeComment,
      productReviews: productReviews,
    );
    loading = false;
    submitted = ok;
    notifyListeners();
    return ok;
  }
}
