class ProductModel {
  final int id;
  final int storeId;
  final int? categoryId;

  final String name;
  final String? description;

  final double price;
  final double? discountPrice;

  final String? image;
  final String? imageUrl;

  final bool isAvailable;
  final int position;

  final String createdAt;
  final String updatedAt;
  final int soldCount;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.image,
    required this.imageUrl,
    required this.isAvailable,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.soldCount = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
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

    return ProductModel(
      id: json["id"],
      storeId: json["store"],
      categoryId: json["category"],
      name: json["name"] ?? "",
      description: json["description"],
      price: _toDouble(json["price"]),
      discountPrice: json["discount_price"] == null
          ? null
          : _toDouble(json["discount_price"]),
      image: json["image"],
      imageUrl: json["image_url"],
      isAvailable: json["is_available"] ?? true,
      position: _toInt(json["position"]),
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      soldCount: _toInt(json["sold_count"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "store": storeId,
      "category": categoryId,
      "name": name,
      "description": description,
      "price": price,
      "discount_price": discountPrice,
      "image": image,
      "image_url": imageUrl,
      "is_available": isAvailable,
      "position": position,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "sold_count": soldCount,
    };
  }
}
