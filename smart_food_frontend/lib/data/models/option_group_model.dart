import 'package:smart_food_frontend/data/models/option_model.dart';

class OptionGroupModel {
  final int id;
  final int productId;
  final String name;
  final bool isRequired;
  final int maxSelect;
  final int position;
  final String createdAt;
  final String updatedAt;

  final List<OptionModel> options;

  OptionGroupModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.isRequired,
    required this.maxSelect,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    required this.options,
  });

  factory OptionGroupModel.fromJson(Map<String, dynamic> json) {
    return OptionGroupModel(
      id: json["id"],
      productId: json["product"],
      name: json["name"] ?? "",
      isRequired: json["is_required"] ?? false,
      maxSelect: json["max_select"] ?? 1,
      position: json["position"] ?? 0,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      options: (json["options"] as List<dynamic>?)
              ?.map((e) => OptionModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
