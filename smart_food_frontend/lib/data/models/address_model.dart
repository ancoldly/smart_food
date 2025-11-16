class AddressModel {
  final int id;
  final String label;
  final bool isDefault;
  final String addressLine;
  final String receiverName;
  final String receiverPhone;

  AddressModel({
    required this.id,
    required this.label,
    required this.isDefault,
    required this.addressLine,
    required this.receiverName,
    required this.receiverPhone,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json["id"],
      label: json["label"] ?? "",
      isDefault: json["is_default"] ?? false,
      addressLine: json["address_line"] ?? "",
      receiverName: json["receiver_name"] ?? "",
      receiverPhone: json["receiver_phone"] ?? "",
    );
  }
}
