class AddressModel {
  final int id;
  final String label;
  final bool isDefault;
  final String addressLine;
  final String receiverName;
  final String receiverPhone;

  final double? latitude;   
  final double? longitude; 

  AddressModel({
    required this.id,
    required this.label,
    required this.isDefault,
    required this.addressLine,
    required this.receiverName,
    required this.receiverPhone,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json["id"],
      label: json["label"] ?? "",
      isDefault: json["is_default"] ?? false,
      addressLine: json["address_line"] ?? "",
      receiverName: json["receiver_name"] ?? "",
      receiverPhone: json["receiver_phone"] ?? "",

      latitude: (json["latitude"] != null)
          ? json["latitude"].toDouble()
          : null,

      longitude: (json["longitude"] != null)
          ? json["longitude"].toDouble()
          : null,
    );
  }
}
