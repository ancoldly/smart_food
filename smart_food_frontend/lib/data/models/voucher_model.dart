class VoucherModel {
  final int id;
  final String code;
  final String title;
  final String? description;
  final String discountType;
  final double discountValue;
  final double? maxDiscountAmount;
  final double minOrderAmount;
  final DateTime? startAt;
  final DateTime? endAt;
  final int? usageLimitTotal;
  final int usageLimitPerUser;
  final int usedCount;
  final bool isActive;

  VoucherModel({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    this.description,
    this.maxDiscountAmount,
    this.startAt,
    this.endAt,
    this.usageLimitTotal,
    this.usageLimitPerUser = 1,
    this.usedCount = 0,
    this.isActive = true,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    double? toD(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return VoucherModel(
      id: json["id"] ?? 0,
      code: json["code"] ?? "",
      title: json["title"] ?? "",
      description: json["description"],
      discountType: json["discount_type"] ?? "",
      discountValue: toD(json["discount_value"]) ?? 0,
      maxDiscountAmount: toD(json["max_discount_amount"]),
      minOrderAmount: toD(json["min_order_amount"]) ?? 0,
      startAt: parseDt(json["start_at"]),
      endAt: parseDt(json["end_at"]),
      usageLimitTotal: json["usage_limit_total"],
      usageLimitPerUser: json["usage_limit_per_user"] ?? 1,
      usedCount: json["used_count"] ?? 0,
      isActive: json["is_active"] ?? true,
    );
  }
}
