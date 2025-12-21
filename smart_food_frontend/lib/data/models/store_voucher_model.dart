class StoreVoucherModel {
  final int id;
  final String code;
  final String description;
  final String discountType; // percent | fixed
  final double discountValue;
  final double minOrderValue;
  final double? maxDiscountValue;
  final String? startDate;
  final String? endDate;
  final int? usageLimit;
  final int usedCount;
  final bool isActive;

  StoreVoucherModel({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.maxDiscountValue,
    required this.startDate,
    required this.endDate,
    required this.usageLimit,
    required this.usedCount,
    required this.isActive,
  });

  factory StoreVoucherModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) =>
        v == null ? 0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0);

    return StoreVoucherModel(
      id: json["id"],
      code: json["code"] ?? "",
      description: json["description"] ?? "",
      discountType: json["discount_type"] ?? "percent",
      discountValue: parseDouble(json["discount_value"]),
      minOrderValue: parseDouble(json["min_order_value"]),
      maxDiscountValue: json["max_discount_value"] == null
          ? null
          : parseDouble(json["max_discount_value"]),
      startDate: json["start_date"],
      endDate: json["end_date"],
      usageLimit: json["usage_limit"],
      usedCount: json["used_count"] ?? 0,
      isActive: json["is_active"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "code": code,
      "description": description,
      "discount_type": discountType,
      "discount_value": discountValue,
      "min_order_value": minOrderValue,
      "max_discount_value": maxDiscountValue,
      "start_date": startDate,
      "end_date": endDate,
      "usage_limit": usageLimit,
      "used_count": usedCount,
      "is_active": isActive,
    };
  }
}
