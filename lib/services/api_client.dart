import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();
  String? _accessToken;
  String? _refreshToken;

  Future<void> setTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> loadTokens() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.deleteAll();
  }

  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: queryParams);
    final resp = await http.get(uri, headers: _headers).timeout(ApiConfig.timeout);
    return _handleResponse(resp);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final resp = await http
        .post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
        .timeout(ApiConfig.timeout);
    return _handleResponse(resp);
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final resp = await http
        .put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
        .timeout(ApiConfig.timeout);
    return _handleResponse(resp);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final resp = await http.delete(uri, headers: _headers).timeout(ApiConfig.timeout);
    return _handleResponse(resp);
  }

  Map<String, dynamic> _handleResponse(http.Response resp) {
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return body;
    }
    final msg = body['error'] ?? body['message'] ?? 'Terjadi kesalahan';
    throw ApiException(msg, resp.statusCode);
  }

  Future<bool> tryRefreshToken() async {
    if (_refreshToken == null) return false;
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/refresh');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': _refreshToken}),
      ).timeout(ApiConfig.timeout);

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final newAccess = body['data']?['access_token'];
        if (newAccess != null) {
          _accessToken = newAccess;
          await _storage.write(key: 'access_token', value: newAccess);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }
}
