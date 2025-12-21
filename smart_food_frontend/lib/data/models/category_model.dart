class CategoryModel {
  final int id;
  final int storeId;

  final String name;
  final String? description;

  final String? image;
  final String? imageUrl;

  final bool isActive;
  final String createdAt;
  final String updatedAt;

  CategoryModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.image,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json["id"],
      storeId: json["store"],
      name: json["name"] ?? "",
      description: json["description"],
      image: json["image"],
      imageUrl: json["image_url"],
      isActive: json["is_active"] ?? true,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "store": storeId,
      "name": name,
      "description": description,
      "image": image,
      "image_url": imageUrl,
      "is_active": isActive,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}
