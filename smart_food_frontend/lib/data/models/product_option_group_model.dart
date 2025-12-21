import 'package:smart_food_frontend/data/models/option_group_template_model.dart';

class ProductOptionGroupModel {
  final int id;
  final int productId;
  final OptionGroupTemplateModel template;
  final bool? isRequired;
  final int? maxSelect;
  final int position;
  final String createdAt;
  final String updatedAt;

  ProductOptionGroupModel({
    required this.id,
    required this.productId,
    required this.template,
    required this.isRequired,
    required this.maxSelect,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductOptionGroupModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return ProductOptionGroupModel(
      id: json["id"],
      productId: json["product"],
      template: OptionGroupTemplateModel.fromJson(json["option_group_template"]),
      isRequired: json["is_required"],
      maxSelect: json["max_select"],
      position: _toInt(json["position"]),
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }
}
