import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/services/leaderboard_service.dart';

class LeaderboardProvider with ChangeNotifier {
  bool loading = false;
  List<Map<String, dynamic>> items = [];
  int myCount = 0;
  int? myRank;
  DateTime? updatedAt;

  Future<void> fetchShipper() async {
    loading = true;
    notifyListeners();
    final data = await LeaderboardService.shipper();
    items = (data["items"] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
    final my = data["my"] as Map<String, dynamic>?;
    myCount = (my?["count"] as num?)?.toInt() ?? 0;
    myRank = my?["rank"] as int?;
    final updated = data["updated_at"]?.toString();
    updatedAt = updated != null ? DateTime.tryParse(updated) : null;
    loading = false;
    notifyListeners();
  }
}
