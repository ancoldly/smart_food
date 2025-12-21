import 'package:smart_food_frontend/data/models/option_template_model.dart';

class OptionGroupTemplateModel {
  final int id;
  final String name;
  final bool isRequired;
  final int maxSelect;
  final int position;
  final String createdAt;
  final String updatedAt;
  final List<OptionTemplateModel> options;

  OptionGroupTemplateModel({
    required this.id,
    required this.name,
    required this.isRequired,
    required this.maxSelect,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    required this.options,
  });

  factory OptionGroupTemplateModel.fromJson(Map<String, dynamic> json) {
    return OptionGroupTemplateModel(
      id: json["id"],
      name: json["name"] ?? "",
      isRequired: json["is_required"] ?? false,
      maxSelect: json["max_select"] ?? 1,
      position: json["position"] ?? 0,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      options: (json["options"] as List<dynamic>?)
              ?.map((e) => OptionTemplateModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
