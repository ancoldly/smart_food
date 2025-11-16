class UserModel {
  final int id;
  final String email;
  final String username;
  final String? fullName;
  final String? phone;
  final String role;
  final String? avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.phone,
    required this.role,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['full_name'],
      phone: json['phone'],
      role: json['role'],
      avatar: json['avatar'],
    );
  }
}
