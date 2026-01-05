import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/services/api_client.dart';

class ReorderService {
  static Future<bool> reorder(int orderId) async {
    final res = await ApiClient.send(
      (token) => http.post(
        Uri.parse("http://10.0.2.2:8000/api/orders/$orderId/reorder/"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    return res.statusCode == 200;
  }
}
