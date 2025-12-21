class FavoriteStoreModel {
  final int id;
  final int storeId;
  final String? createdAt;

  FavoriteStoreModel({
    required this.id,
    required this.storeId,
    this.createdAt,
  });

  factory FavoriteStoreModel.fromJson(Map<String, dynamic> json) {
    return FavoriteStoreModel(
      id: json["id"] ?? 0,
      storeId: json["store"] ?? 0,
      createdAt: json["created_at"],
    );
  }
}
