import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = "http://197.239.116.77:3000/api/v1";

  static Future<http.Response> get(String endpoint) async {
    return _request("GET", endpoint);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return _request("POST", endpoint, body: body);
  }

  static Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';

    http.Response response;

    final uri = Uri.parse("$baseUrl$endpoint");

    if (method == "POST") {
      response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    } else {
      response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
    }

    // ⬇️ ICI EST LA MAGIE 🔥
    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        return _request(method, endpoint, body: body);
      }
    }

    return response;
  }

static Future<bool> _refreshToken() async {
  final prefs = await SharedPreferences.getInstance();

  // 1️⃣ Vérifier la durée de session
  final loginTimestamp = prefs.getInt('loginTimestamp');
  if (loginTimestamp == null) return false;

  final now = DateTime.now().millisecondsSinceEpoch;

  // ⛔ Session trop ancienne → refus du refresh
  if (now - loginTimestamp > maxSessionDurationMs) {
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('loginTimestamp');
    return false;
  }

  // 2️⃣ Continuer normalement si session encore valide
  final refreshToken = prefs.getString('refreshToken');
  if (refreshToken == null) return false;

  final response = await http.post(
    Uri.parse("$baseUrl/auth/refresh"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'refreshToken': refreshToken}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'];
    await prefs.setString('accessToken', data['accessToken']);
    await prefs.setString('refreshToken', data['refreshToken']);
    return true;
  }

  return false;
}

}
