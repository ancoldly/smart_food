class OrderModel {
  final int id;
  final int storeId;
  final String storeName;
  final String storeAvatar;
  final String storeAddress;
  final String addressLine;
  final String receiverName;
  final String receiverPhone;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final int itemCount;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final int? shipperId;
  final String shipperName;
  final double merchantEarning;
  final double shipperEarning;
  final double? storeLatitude;
  final double? storeLongitude;
  final double? destLatitude;
  final double? destLongitude;

  OrderModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.storeAvatar,
    required this.storeAddress,
    required this.addressLine,
    required this.receiverName,
    required this.receiverPhone,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    required this.itemCount,
    required this.items,
    required this.createdAt,
    this.shipperId,
    this.shipperName = "",
    this.merchantEarning = 0,
    this.shipperEarning = 0,
    this.storeLatitude,
    this.storeLongitude,
    this.destLatitude,
    this.destLongitude,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double toD(dynamic v) =>
        v == null ? 0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0);
    String toS(dynamic v) => v == null ? "" : v.toString();
    final itemsJson = (json["items"] as List?) ?? [];
    return OrderModel(
      id: json["id"] ?? 0,
      storeId: json["store"] ?? 0,
      storeName: toS(json["store_name"]),
      storeAvatar: toS(json["store_avatar"]),
      storeAddress: toS(json["store_address"]),
      addressLine: toS(json["address_line"]),
      receiverName: toS(json["receiver_name"]),
      receiverPhone: toS(json["receiver_phone"]),
      status: toS(json["status"]),
      paymentMethod: toS(json["payment_method"]),
      paymentStatus: toS(json["payment_status"]),
      subtotal: toD(json["subtotal"]),
      shippingFee: toD(json["shipping_fee"]),
      discount: toD(json["discount"]),
      total: toD(json["total"]),
      itemCount: json["item_count"] ?? 0,
      items: itemsJson.map((e) => OrderItemModel.fromJson(e)).toList(),
      createdAt: DateTime.tryParse(toS(json["created_at"])) ?? DateTime.now(),
      shipperId: json["shipper_id"],
      shipperName: toS(json["shipper_name"]),
      merchantEarning: toD(json["merchant_earning"]),
      shipperEarning: toD(json["shipper_earning"]),
      storeLatitude: json["store_latitude"] == null ? null : toD(json["store_latitude"]),
      storeLongitude: json["store_longitude"] == null ? null : toD(json["store_longitude"]),
      destLatitude: json["dest_latitude"] == null ? null : toD(json["dest_latitude"]),
      destLongitude: json["dest_longitude"] == null ? null : toD(json["dest_longitude"]),
    );
  }
}

class OrderItemModel {
  final int id;
  final int productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final String productImage;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.productImage,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    double toD(dynamic v) =>
        v == null ? 0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0);
    String toS(dynamic v) => v == null ? "" : v.toString();
    return OrderItemModel(
      id: json["id"] ?? 0,
      productId: json["product_id"] ?? 0,
      name: toS(json["product_name"]),
      quantity: json["quantity"] ?? 0,
      unitPrice: toD(json["unit_price"]),
      lineTotal: toD(json["line_total"]),
      productImage: toS(json["product_image"]),
    );
  }
}
