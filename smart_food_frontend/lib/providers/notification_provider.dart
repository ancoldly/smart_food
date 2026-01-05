import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/notification_model.dart';
import 'package:smart_food_frontend/data/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _items = [];
  bool _loading = false;
  int _unreadCount = 0;

  List<NotificationModel> get items => _items;
  bool get loading => _loading;
  int get unreadCount => _unreadCount;

  Future<void> fetchNotifications({bool unreadOnly = false}) async {
    _loading = true;
    notifyListeners();
    _items = await NotificationService.fetchAll(unreadOnly: unreadOnly);
    _unreadCount = _items.where((e) => !e.isRead).length;
    _loading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    final ok = await NotificationService.markRead(id);
    if (ok) {
      _items = _items
          .map((n) => n.id == id ? NotificationModel.fromJson({..._toMap(n), "is_read": true}) : n)
          .toList();
      _unreadCount = _items.where((e) => !e.isRead).length;
      notifyListeners();
    }
  }

  Future<void> refreshUnreadCount() async {
    _unreadCount = await NotificationService.unreadCount();
    notifyListeners();
  }

  Map<String, dynamic> _toMap(NotificationModel n) => {
        "id": n.id,
        "title": n.title,
        "message": n.message,
        "is_read": n.isRead,
        "order_id": n.orderId,
        "created_at": n.createdAt.toIso8601String(),
      };
}
