import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/payment_model.dart';
import 'package:smart_food_frontend/data/services/api_client.dart';

class PaymentService {
  static const String baseUrl = "http://10.0.2.2:8000/api/payments";

  static Future<List<PaymentModel>> fetchPayments() async {
    final res = await ApiClient.send((token) {
      return http.get(
        Uri.parse("$baseUrl/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => PaymentModel.fromJson(e)).toList();
    }

    return [];
  }

  static Future<bool> createPayment({
    required Map<String, String> fields,
    File? bankLogoFile,
  }) async {
    final uri = Uri.parse("$baseUrl/");
  
    final res = await ApiClient.sendMultipart((token) async {
      final req = http.MultipartRequest("POST", uri);

      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";

      fields.forEach((key, value) {
        req.fields[key] = value;
      });

      if (bankLogoFile != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            "bank_logo",
            bankLogoFile.path,
          ),
        );
      }

      return req;
    });

    return res.statusCode == 201;
  }

  static Future<bool> updatePayment(int id, Map<String, dynamic> body) async {
    final res = await ApiClient.send((token) {
      return http.put(
        Uri.parse("$baseUrl/$id/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    });

    return res.statusCode == 200;
  }

  static Future<bool> deletePayment(int id) async {
    final res = await ApiClient.send((token) {
      return http.delete(
        Uri.parse("$baseUrl/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 204;
  }

  static Future<bool> setDefault(int id) async {
    final res = await ApiClient.send((token) {
      return http.post(
        Uri.parse("$baseUrl/$id/set-default/"),
        headers: {"Authorization": "Bearer $token"},
      );
    });

    return res.statusCode == 200;
  }
}
