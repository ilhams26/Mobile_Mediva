import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// HTTP client terpusat yang menangani header dan autentikasi JWT secara otomatis.
///
/// Semua pemanggilan API harus melewati class ini agar:
/// - Token hanya diambil dari SharedPreferences di satu tempat
/// - Header `Accept` dan `Authorization` selalu konsisten
/// - Tidak ada duplikasi boilerplate di setiap method service
class HttpClient {
  HttpClient._();

  /// Mengambil token JWT yang tersimpan, atau `null` jika belum login.
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.tokenKey);
  }

  /// Menyimpan token JWT setelah login berhasil.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, token);
  }

  /// Menghapus token JWT saat logout.
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
  }

  /// Membangun header standar dengan opsional autentikasi.
  static Future<Map<String, String>> _buildHeaders({
    bool authenticated = true,
    bool jsonContent = false,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};

    if (jsonContent) {
      headers['Content-Type'] = 'application/json';
    }

    if (authenticated) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// [endpoint] path relatif terhadap baseUrl (contoh: `/me`, `/obats`).
  /// [authenticated] jika `true`, token JWT akan disertakan.
  /// [queryParams] parameter query opsional.
  static Future<http.Response> get(
    String endpoint, {
    bool authenticated = true,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$endpoint',
    ).replace(queryParameters: queryParams);
    final headers = await _buildHeaders(authenticated: authenticated);
    return http.get(uri, headers: headers);
  }

  /// HTTP POST request dengan body form-data.
  static Future<http.Response> post(
    String endpoint, {
    bool authenticated = true,
    Map<String, String>? body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await _buildHeaders(authenticated: authenticated);
    return http.post(uri, headers: headers, body: body);
  }

  /// HTTP POST request dengan body JSON.
  static Future<http.Response> postJson(
    String endpoint, {
    bool authenticated = true,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await _buildHeaders(
      authenticated: authenticated,
      jsonContent: true,
    );
    return http.post(uri, headers: headers, body: json.encode(body));
  }

  /// HTTP PUT request dengan body form-data.
  static Future<http.Response> put(
    String endpoint, {
    bool authenticated = true,
    Map<String, String>? body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await _buildHeaders(authenticated: authenticated);
    return http.put(uri, headers: headers, body: body);
  }

  /// HTTP PATCH request.
  static Future<http.Response> patch(
    String endpoint, {
    bool authenticated = true,
    Map<String, String>? body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await _buildHeaders(authenticated: authenticated);
    return http.patch(uri, headers: headers, body: body);
  }

  /// HTTP Multipart POST untuk upload file.
  static Future<http.Response> uploadFile(
    String endpoint, {
    required String fileField,
    required String filePath,
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final token = await _getToken();

    final request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }
}
