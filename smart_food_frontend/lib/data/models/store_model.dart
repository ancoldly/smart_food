class StoreModel {
  final int id;

  final String category;
  final String storeName;
  final String city;
  final String address;

  final String managerName;
  final String managerPhone;
  final String managerEmail;

  final double? latitude;
  final double? longitude;

  final String backgroundImage;
  final int status;

  StoreModel({
    required this.id,
    required this.category,
    required this.storeName,
    required this.city,
    required this.address,
    required this.managerName,
    required this.managerPhone,
    required this.managerEmail,
    required this.latitude,
    required this.longitude,
    required this.backgroundImage,
    required this.status,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json["id"],
      category: json["category"] ?? "",
      storeName: json["store_name"] ?? "",
      city: json["city"] ?? "",
      address: json["address"] ?? "",
      managerName: json["manager_name"] ?? "",
      managerPhone: json["manager_phone"] ?? "",
      managerEmail: json["manager_email"] ?? "",
      latitude: json["latitude"] == null
          ? null
          : (json["latitude"] as num).toDouble(),
      longitude: json["longitude"] == null
          ? null
          : (json["longitude"] as num).toDouble(),
      backgroundImage: json["background_image"] ?? "",
      status: json["status"] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "category": category,
      "store_name": storeName,
      "city": city,
      "address": address,
      "manager_name": managerName,
      "manager_phone": managerPhone,
      "manager_email": managerEmail,
      "latitude": latitude,
      "longitude": longitude,
      "background_image": backgroundImage,
      "status": status,
    };
  }
}
