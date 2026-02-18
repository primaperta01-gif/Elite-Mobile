import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();
  final _apiClient = ApiClient();

  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  String get role => _user?.role ?? '';

  Future<bool> tryAutoLogin() async {
    await _apiClient.loadTokens();
    if (!_apiClient.isLoggedIn) return false;
    try {
      _user = await _authService.getMe();
      notifyListeners();
      return true;
    } catch (_) {
      final refreshed = await _apiClient.tryRefreshToken();
      if (refreshed) {
        try {
          _user = await _authService.getMe();
          notifyListeners();
          return true;
        } catch (_) {}
      }
      await _apiClient.clearTokens();
      return false;
    }
  }

  Future<bool> login(String uid, String password, {String? role}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authService.login(uid, password, role: role);
      _user = result.user;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
