import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/models/store_operating_hour_model.dart';
import 'package:smart_food_frontend/data/models/store_voucher_model.dart';
import 'package:smart_food_frontend/data/models/store_campaign_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class StoreService {
  static const String baseUrl = "http://10.0.2.2:8000/api/stores";

  // =============================
  //   ADMIN: GET ALL STORES
  // =============================
  static Future<List<StoreModel>> fetchStoresAdmin() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/admin/all/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => StoreModel.fromJson(e)).toList();
    }
    return [];
  }

  // =============================
  //   PUBLIC: GET APPROVED STORES
  // =============================
  static Future<List<StoreModel>> fetchStoresPublic() async {
    final res = await http.get(Uri.parse("$baseUrl/public/"));
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => StoreModel.fromJson(e)).toList();
    }
    return [];
  }

  // PUBLIC: GET STORES BY PRODUCT CATEGORY (name or id)
  static Future<List<StoreModel>> fetchStoresByCategory({
    required String categoryName,
  }) async {
    final uri = Uri.parse("$baseUrl/public/")
        .replace(queryParameters: {"product_category": categoryName.trim()});
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => StoreModel.fromJson(e)).toList();
    }
    return [];
  }

  // PUBLIC: SEARCH STORES BY KEYWORD (no split)
  static Future<List<StoreModel>> fetchStoresByKeyword({
    required String keyword,
  }) async {
    final uri = Uri.parse("$baseUrl/public/")
        .replace(queryParameters: {"keyword": keyword.trim()});
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => StoreModel.fromJson(e)).toList();
    }
    return [];
  }

  // =============================
  //   USER: GET MY STORE (ONE)
  // =============================
  static Future<StoreModel?> fetchMyStore() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/me/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      if (decoded.isEmpty || decoded == "null") {
        return null;
      }

      final data = jsonDecode(decoded);
      if (data == null) return null;

      return StoreModel.fromJson(data);
    }

    return null;
  }

  // =============================
  //   CREATE STORE (MULTIPART)
  // =============================
  static Future<bool> createStore({
    required Map<String, String> fields,
    File? avatarImage,
    File? backgroundImage,
  }) async {
    final uri = Uri.parse("$baseUrl/create/");

    final res = await ApiClient.sendMultipart((token) async {
      final req = http.MultipartRequest("POST", uri);

      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";

      // Add fields
      fields.forEach((key, value) => req.fields[key] = value);

      // Add avatar image
      if (avatarImage != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            "avatar_image", // <─ ĐÚNG FIELD BACKEND
            avatarImage.path,
          ),
        );
      }

      // Add background image
      if (backgroundImage != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            "background_image", // <─ ĐÚNG FIELD BACKEND
            backgroundImage.path,
          ),
        );
      }

      return req;
    });

    return res.statusCode == 201;
  }

  // =============================
  //   UPDATE STORE (MULTIPART)
  // =============================
  static Future<bool> updateStore({
    required int id,
    required Map<String, String> fields,
    File? backgroundImage,
    File? avatarImage,
  }) async {
    final uri = Uri.parse("$baseUrl/$id/");

    final res = await ApiClient.sendMultipart((token) async {
      final req = http.MultipartRequest("PATCH", uri);

      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";

      // Add text fields
      fields.forEach((key, value) {
        req.fields[key] = value;
      });

      // Add image if exists
      if (backgroundImage != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            "background_image",
            backgroundImage.path,
          ),
        );
      }

      if (avatarImage != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            "avatar_image",
            avatarImage.path,
          ),
        );
      }

      return req;
    });

    return res.statusCode == 200;
  }

  // =============================
  //   DELETE STORE
  // =============================
  static Future<bool> deleteStore(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 204;
  }

  // =============================
  //   ADMIN: APPROVE STORE
  // =============================
  static Future<bool> approveStore(int id) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/admin/$id/approve/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 200;
  }

  // =============================
  //   ADMIN: REJECT STORE
  // =============================
  static Future<bool> rejectStore(int id) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/admin/$id/reject/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 200;
  }

  // =============================
  //   MERCHANT: TOGGLE STORE
  // =============================
  static Future<bool> toggleStore(int id) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/$id/toggle/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 200;
  }

  // =============================
  //   MERCHANT: OPERATING HOURS
  // =============================
  static Future<List<StoreOperatingHourModel>> fetchOperatingHours() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/hours/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => StoreOperatingHourModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<bool> updateOperatingHour({
    required int id,
    required bool isClosed,
    String? openTime,
    String? closeTime,
  }) async {
    final body = {
      "is_closed": isClosed,
      if (openTime != null) "open_time": openTime,
      if (closeTime != null) "close_time": closeTime,
    };

    final res = await ApiClient.send((token) {
      return http.patch(
        Uri.parse("$baseUrl/hours/$id/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    });

    return res.statusCode == 200;
  }

  // =============================
  //   MERCHANT: STORE VOUCHERS
  // =============================
  static Future<List<StoreVoucherModel>> fetchStoreVouchers() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/vouchers/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => StoreVoucherModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<StoreVoucherModel?> createStoreVoucher(
      Map<String, dynamic> payload) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/vouchers/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );
    });

    if (res.statusCode == 201) {
      final decoded = utf8.decode(res.bodyBytes);
      return StoreVoucherModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<StoreVoucherModel?> updateStoreVoucher(
      int id, Map<String, dynamic> payload) async {
    final res = await ApiClient.send((token) {
      return http.patch(
        Uri.parse("$baseUrl/vouchers/$id/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return StoreVoucherModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<bool> deleteStoreVoucher(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/vouchers/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 204;
  }

  // =============================
  //   MERCHANT: STORE CAMPAIGNS
  // =============================
  static Future<List<StoreCampaignModel>> fetchStoreCampaigns() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/campaigns/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => StoreCampaignModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<StoreCampaignModel?> createStoreCampaign(
      Map<String, dynamic> payload) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/campaigns/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );
    });
    if (res.statusCode == 201) {
      final decoded = utf8.decode(res.bodyBytes);
      return StoreCampaignModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<StoreCampaignModel?> updateStoreCampaign(
      int id, Map<String, dynamic> payload) async {
    final res = await ApiClient.send((token) {
      return http.patch(
        Uri.parse("$baseUrl/campaigns/$id/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );
    });
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return StoreCampaignModel.fromJson(jsonDecode(decoded));
    }
    return null;
  }

  static Future<bool> deleteStoreCampaign(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/campaigns/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 204;
  }

  static Future<void> trackCampaignImpression(int id) async {
    try {
      await http.post(Uri.parse("$baseUrl/campaigns/$id/impression/"));
    } catch (_) {}
  }

  static Future<void> trackCampaignClick(int id) async {
    try {
      await http.post(Uri.parse("$baseUrl/campaigns/$id/click/"));
    } catch (_) {}
  }
}
