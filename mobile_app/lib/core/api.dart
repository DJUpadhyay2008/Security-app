import 'dart:convert';
import 'package:http/http.dart' as http;

// If testing from Android Emulator, you might need to use http://10.0.2.2:8080 instead of localhost
// 10.0.2.2 points to host's localhost on Android Emulator.
const String baseUrl = 'http://localhost:8080';

class ApiService {
  static final _client = http.Client();

  static Future<dynamic> get(String path, {Map<String, String>? params, bool isJson = true}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: params);
    final res = await _client.get(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (!isJson) return res.body;
      if (res.body.isEmpty) return null;
      try {
        return jsonDecode(res.body);
      } catch (_) {
        return res.body;
      }
    }
    throw ApiException(res.statusCode, _parseError(res.body));
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await _client.post(uri,
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      try {
        return jsonDecode(res.body);
      } catch (_) {
        return res.body;
      }
    }
    throw ApiException(res.statusCode, _parseError(res.body));
  }
  
  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await _client.put(uri,
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      try {
        return jsonDecode(res.body);
      } catch (_) {
        return res.body;
      }
    }
    throw ApiException(res.statusCode, _parseError(res.body));
  }

  static String _parseError(String body) {
    try {
      final map = jsonDecode(body);
      return map['message'] ?? body;
    } catch (_) {
      return body;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'Error $statusCode: $message';
}
