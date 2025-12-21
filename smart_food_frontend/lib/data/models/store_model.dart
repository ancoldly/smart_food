import 'store_tag_model.dart';
import 'store_operating_hour_model.dart';
import 'store_campaign_model.dart';
import 'store_voucher_model.dart';
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

  final String? avatarImage;
  final String? backgroundImage;
  final List<StoreTagModel> tags;
  final int status;
  final List<StoreOperatingHourModel> operatingHours;
  final List<StoreCampaignModel> campaigns;
  final List<StoreVoucherModel> storeVouchers;

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
    required this.avatarImage,
    required this.backgroundImage,
    required this.tags,
    required this.status,
    required this.operatingHours,
    required this.campaigns,
    this.storeVouchers = const [],
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
      avatarImage: json["avatar_image"] ?? "",
      backgroundImage: json["background_image"] ?? "",
      tags: (json["tags"] as List?)
              ?.map((e) => StoreTagModel.fromJson(e))
              .toList() ??
          [],
      status: json["status"] ?? 1,
      operatingHours: (json["operating_hours"] as List?)
              ?.map((e) => StoreOperatingHourModel.fromJson(e))
              .toList() ??
          [],
      campaigns: (json["campaigns"] as List?)
              ?.map((e) => StoreCampaignModel.fromJson(e))
              .toList() ??
          [],
      storeVouchers: (json["store_vouchers"] as List?)
              ?.map((e) => StoreVoucherModel.fromJson(e))
              .toList() ??
          [],
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
      "avatar_image": avatarImage,
      "background_image": backgroundImage,
      "tags": tags.map((e) => e.toJson()).toList(),
      "status": status,
      "operating_hours": operatingHours.map((e) => e.toJson()).toList(),
      "campaigns": campaigns.map((e) => e.toJson()).toList(),
      "store_vouchers": storeVouchers.map((e) => e.toJson()).toList(),
    };
  }
}
