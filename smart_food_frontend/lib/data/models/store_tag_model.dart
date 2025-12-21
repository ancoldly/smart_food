class StoreTagModel {
  final int id;
  final String name;
  final String slug;

  StoreTagModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory StoreTagModel.fromJson(Map<String, dynamic> json) {
    return StoreTagModel(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
      };
}
