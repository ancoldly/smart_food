class OptionTemplateModel {
  final int id;
  final int optionGroupTemplateId;
  final String name;
  final double price;
  final int position;
  final String createdAt;
  final String updatedAt;

  OptionTemplateModel({
    required this.id,
    required this.optionGroupTemplateId,
    required this.name,
    required this.price,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OptionTemplateModel.fromJson(Map<String, dynamic> json) {
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

    return OptionTemplateModel(
      id: json["id"],
      optionGroupTemplateId: json["option_group_template"],
      name: json["name"] ?? "",
      price: _toDouble(json["price"]),
      position: _toInt(json["position"]),
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }
}
