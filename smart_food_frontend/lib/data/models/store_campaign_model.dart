class StoreCampaignModel {
  final int id;
  final int storeId;
  final String title;
  final String description;
  final String bannerUrl;
  final String? startDate;
  final String? endDate;
  final double budget;
  final int impressions;
  final int clicks;
  final bool isActive;

  StoreCampaignModel({
    required this.id,
    required this.storeId,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.impressions,
    required this.clicks,
    required this.isActive,
  });

  factory StoreCampaignModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) =>
        v == null ? 0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0);
    return StoreCampaignModel(
      id: json["id"],
      storeId: json["store"] ?? 0,
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      bannerUrl: json["banner_url"] ?? "",
      startDate: json["start_date"],
      endDate: json["end_date"],
      budget: parseDouble(json["budget"]),
      impressions: json["impressions"] ?? 0,
      clicks: json["clicks"] ?? 0,
      isActive: json["is_active"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "store": storeId,
      "title": title,
      "description": description,
      "banner_url": bannerUrl,
      "start_date": startDate,
      "end_date": endDate,
      "budget": budget,
      "impressions": impressions,
      "clicks": clicks,
      "is_active": isActive,
    };
  }
}
