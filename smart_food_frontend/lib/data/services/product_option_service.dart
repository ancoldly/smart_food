import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:smart_food_frontend/data/models/option_group_model.dart';

class ProductOptionService {
  static const String baseUrl = "http://10.0.2.2:8000/api/products";

  static Future<List<OptionGroupModel>> fetchPublicOptions(int productId) async {
    final res =
        await http.get(Uri.parse("$baseUrl/public/$productId/options/"));
    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final List data = jsonDecode(decoded);
      return data.map((e) => OptionGroupModel.fromJson(e)).toList();
    }
    return [];
  }
}
