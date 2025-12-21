class StoreOperatingHourModel {
  final int id;
  final int dayOfWeek; // 0 = Monday, 6 = Sunday
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  StoreOperatingHourModel({
    required this.id,
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  factory StoreOperatingHourModel.fromJson(Map<String, dynamic> json) {
    return StoreOperatingHourModel(
      id: json["id"],
      dayOfWeek: json["day_of_week"] ?? 0,
      openTime: json["open_time"],
      closeTime: json["close_time"],
      isClosed: json["is_closed"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "day_of_week": dayOfWeek,
      "open_time": openTime,
      "close_time": closeTime,
      "is_closed": isClosed,
    };
  }
}
