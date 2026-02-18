import '../models/auth_result.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final _api = ApiClient();

  Future<AuthResult> login(String uid, String password, {String? role}) async {
    final body = <String, dynamic>{
      'uid': uid,
      'password': password,
      if (role != null && role.isNotEmpty) 'role': role,
    };
    final resp = await _api.post('/auth/login', body: body);
    final result = AuthResult.fromJson(resp['data']);
    await _api.setTokens(result.accessToken, result.refreshToken);
    return result;
  }

  Future<User> getMe() async {
    final resp = await _api.get('/auth/me');
    return User.fromJson(resp['data']);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _api.clearTokens();
  }
}
