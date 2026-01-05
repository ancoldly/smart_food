class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final int? orderId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.orderId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String toS(dynamic v) => v == null ? "" : v.toString();
    return NotificationModel(
      id: json["id"] ?? 0,
      title: toS(json["title"]),
      message: toS(json["message"]),
      isRead: json["is_read"] ?? false,
      orderId: json["order_id"],
      createdAt: DateTime.tryParse(toS(json["created_at"])) ?? DateTime.now(),
    );
  }
}
