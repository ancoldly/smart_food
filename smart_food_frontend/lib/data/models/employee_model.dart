class EmployeeModel {
  final int id;

  final int storeId;

  final String fullName;
  final String phone;
  final String? email;

  final String role;       // staff / cashier / manager / delivery
  final int status;        // 1 / 2 / 3

  final String? avatarImage;  // absolute URL from backend

  EmployeeModel({
    required this.id,
    required this.storeId,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.role,
    required this.status,
    required this.avatarImage,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json["id"],
      storeId: json["store"],

      fullName: json["full_name"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"],

      role: json["role"] ?? "staff",
      status: json["status"] ?? 1,

      avatarImage: json["avatar_image"], // URL đã build ở serializer
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "store": storeId,
      "full_name": fullName,
      "phone": phone,
      "email": email,
      "role": role,
      "status": status,
      "avatar_image": avatarImage,
    };
  }
}
