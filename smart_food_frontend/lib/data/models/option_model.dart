class OptionModel {
  final int id;
  final int optionGroupId;
  final String name;
  final double price;
  final int position;
  final String createdAt;
  final String updatedAt;

  OptionModel({
    required this.id,
    required this.optionGroupId,
    required this.name,
    required this.price,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return OptionModel(
      id: json["id"],
      optionGroupId: json["option_group"],
      name: json["name"] ?? "",
      price: _toDouble(json["price"]),
      position: _toInt(json["position"]),
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }
}
