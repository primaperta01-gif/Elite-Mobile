import 'dart:async';
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
  Timer? _sessionTimer;

  static const _sessionTimeout = Duration(hours: 12);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  User? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  String get role => _user?.role ?? '';

  AuthProvider() {
    _apiClient.onSessionExpired = _handleSessionExpired;
  }

  void _handleSessionExpired() {
    _user = null;
    _error = null;
    _sessionTimer?.cancel();
    notifyListeners();
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }

  void _resetSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(_sessionTimeout, () {
      _handleSessionExpired();
    });
  }

  void resetActivityTimer() => _resetSessionTimer();

  Future<bool> tryAutoLogin() async {
    await _apiClient.loadTokens();
    if (!_apiClient.isLoggedIn) return false;
    try {
      _user = await _authService.getMe();
      _resetSessionTimer();
      notifyListeners();
      return true;
    } catch (_) {
      final refreshed = await _apiClient.tryRefreshToken();
      if (refreshed) {
        try {
          _user = await _authService.getMe();
          _resetSessionTimer();
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
      _resetSessionTimer();
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
    _sessionTimer?.cancel();
    await _authService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
