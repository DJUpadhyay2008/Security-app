import 'dart:convert';
import 'package:http/http.dart' as http;

/// ⚠️ CONNECTION NOTE:
/// - If using Android Emulator: Use 'http://10.0.2.2:8080'
/// - If using iOS Simulator: Use 'http://localhost:8080'
/// - If using Physical Device: Use your computer's local IP (e.g., 'http://192.168.1.X:8080')
/// - For production: Use your deployed server URL.
const String baseUrl = 'http://localhost:8080';

class ApiService {
  static final _client = http.Client();

  static Future<dynamic> get(String path, {Map<String, String>? params, bool isJson = true}) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: params);
      final res = await _client.get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 5));
          
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
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(503, 'Could not connect to server. Check your baseUrl in core/api.dart');
    }
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.body.isEmpty) return null;
        try {
          return jsonDecode(res.body);
        } catch (_) {
          return res.body;
        }
      }
      throw ApiException(res.statusCode, _parseError(res.body));
    } catch (e) {
       if (e is ApiException) rethrow;
       throw ApiException(503, 'Network error. Make sure your phone is on the same Wi-Fi as your PC and using the correct IP.');
    }
  }
  
  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final res = await _client.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.body.isEmpty) return null;
        try {
          return jsonDecode(res.body);
        } catch (_) {
          return res.body;
        }
      }
      throw ApiException(res.statusCode, _parseError(res.body));
    } catch (e) {
       if (e is ApiException) rethrow;
       throw ApiException(503, 'Server unreachable.');
    }
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
  String toString() => message;
}
