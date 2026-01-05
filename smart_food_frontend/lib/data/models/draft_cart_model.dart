import 'package:smart_food_frontend/data/models/store_voucher_model.dart';

class DraftCartModel {
  final int cartId;
  final int storeId;
  final String storeName;
  final String storeAddress;
  final String storeCity;
  final String storeAvatar;
  final double total;
  final int itemCount;
  final List<StoreVoucherModel> storeVouchers;
  final double? latitude;
  final double? longitude;

  DraftCartModel({
    required this.cartId,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.storeCity,
    required this.storeAvatar,
    required this.total,
    required this.itemCount,
    this.storeVouchers = const [],
    this.latitude,
    this.longitude,
  });

  factory DraftCartModel.fromJson(Map<String, dynamic> json) {
    List<StoreVoucherModel> _vouchers(dynamic v) {
      if (v is List) {
        return v.map((e) => StoreVoucherModel.fromJson(e)).toList();
      }
      return [];
    }

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

    return DraftCartModel(
      cartId: _toInt(json["cart_id"]),
      storeId: _toInt(json["store_id"]),
      storeName: json["store_name"] ?? "",
      storeAddress: json["store_address"] ?? "",
      storeCity: json["store_city"] ?? "",
      storeAvatar: json["store_avatar"] ?? "",
      total: _toDouble(json["total"]),
      itemCount: _toInt(json["item_count"]),
      storeVouchers: _vouchers(json["store_vouchers"]),
      latitude: json["store_latitude"] == null ? null : _toDouble(json["store_latitude"]),
      longitude: json["store_longitude"] == null ? null : _toDouble(json["store_longitude"]),
    );
  }
}
