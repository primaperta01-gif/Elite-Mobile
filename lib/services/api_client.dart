import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
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

class SessionExpiredException extends ApiException {
  SessionExpiredException() : super('Sesi telah berakhir. Silakan login ulang.', 401);
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _accessToken;
  String? _refreshToken;
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshQueue = [];

  // Global callback for session expired — set by AuthProvider
  VoidCallback? onSessionExpired;

  Future<void> setTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    await Future.wait([
      _storage.write(key: 'access_token', value: access),
      _storage.write(key: 'refresh_token', value: refresh),
    ]);
  }

  Future<void> loadTokens() async {
    final results = await Future.wait([
      _storage.read(key: 'access_token'),
      _storage.read(key: 'refresh_token'),
    ]);
    _accessToken = results[0];
    _refreshToken = results[1];
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.deleteAll();
  }

  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    return _requestWithRetry(() async {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path')
          .replace(queryParameters: queryParams);
      return http.get(uri, headers: _headers).timeout(ApiConfig.timeout);
    });
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    return _requestWithRetry(() async {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      return http
          .post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConfig.timeout);
    });
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    return _requestWithRetry(() async {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      return http
          .put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConfig.timeout);
    });
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _requestWithRetry(() async {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      return http.delete(uri, headers: _headers).timeout(ApiConfig.timeout);
    });
  }

  /// Wraps every request: on 401 → refresh token → retry once.
  Future<Map<String, dynamic>> _requestWithRetry(
    Future<http.Response> Function() doRequest,
  ) async {
    final resp = await doRequest();

    if (resp.statusCode == 401 && _accessToken != null) {
      final refreshed = await _safeRefreshToken();
      if (refreshed) {
        final retryResp = await doRequest();
        return _handleResponse(retryResp);
      }
      await clearTokens();
      onSessionExpired?.call();
      throw SessionExpiredException();
    }

    return _handleResponse(resp);
  }

  Map<String, dynamic> _handleResponse(http.Response resp) {
    Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(resp.body);
      body = decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    } on FormatException {
      throw ApiException(
        'Server error (${resp.statusCode}): Response bukan JSON',
        resp.statusCode,
      );
    }
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return body;
    }
    if (resp.statusCode == 401) {
      throw SessionExpiredException();
    }
    final msg = body['error'] ?? body['message'] ?? 'Terjadi kesalahan (${resp.statusCode})';
    throw ApiException(msg is String ? msg : msg.toString(), resp.statusCode);
  }

  /// Prevents multiple concurrent refresh calls — queues them behind one.
  Future<bool> _safeRefreshToken() async {
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshQueue.add(completer);
      await completer.future;
      return _accessToken != null;
    }

    _isRefreshing = true;
    try {
      final success = await tryRefreshToken();
      for (final c in _refreshQueue) {
        c.complete();
      }
      _refreshQueue.clear();
      return success;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<bool> tryRefreshToken() async {
    if (_refreshToken == null) return false;
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/refresh');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'refresh_token': _refreshToken}),
      ).timeout(ApiConfig.timeout);

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic>) {
          final newAccess = decoded['data']?['access_token'];
          if (newAccess is String && newAccess.isNotEmpty) {
            _accessToken = newAccess;
            await _storage.write(key: 'access_token', value: newAccess);
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }
}
