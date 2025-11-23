import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/services/auth_service.dart';
import 'package:smart_food_frontend/data/services/token_storage.dart';

class ApiClient {
  static Future<http.Response> send(
      Future<http.Response> Function(String token) request) async {
    String? token = await TokenStorage.getAccessToken();
    if (token == null) {
      return http.Response("Unauthorized", 401);
    }

    http.Response res = await request(token);

    if (res.statusCode == 401) {
      final refresh = await TokenStorage.getRefreshToken();
      if (refresh == null) return res;

      final newAccess = await AuthService().refreshAccessToken(refresh);
      if (newAccess == null) return res;

      await TokenStorage.saveTokens(newAccess, refresh);

      res = await request(newAccess);
    }

    return res;
  }

  static Future<http.Response> sendMultipart(
      Future<http.MultipartRequest> Function(String token) buildRequest) async {
    String? token = await TokenStorage.getAccessToken();
    if (token == null) {
      return http.Response("Unauthorized", 401);
    }

    http.MultipartRequest req = await buildRequest(token);
    http.StreamedResponse streamRes;

    try {
      streamRes = await req.send();
    } catch (e) {
      return http.Response("Send error", 500);
    }

    http.Response res = await http.Response.fromStream(streamRes);

    if (res.statusCode != 401) return res;

    final refresh = await TokenStorage.getRefreshToken();
    if (refresh == null) return res;

    final newAccess = await AuthService().refreshAccessToken(refresh);
    if (newAccess == null) return res;

    await TokenStorage.saveTokens(newAccess, refresh);

    http.MultipartRequest retryReq = await buildRequest(newAccess);

    http.StreamedResponse retryStream;

    try {
      retryStream = await retryReq.send();
    } catch (e) {
      return http.Response("Retry error", 500);
    }

    final retryResponse = await http.Response.fromStream(retryStream);
    return retryResponse;
  }
}
