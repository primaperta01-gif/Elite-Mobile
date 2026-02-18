import 'user.dart';

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        accessToken: json['access_token'] ?? '',
        refreshToken: json['refresh_token'] ?? '',
        user: User.fromJson(json['user'] ?? {}),
      );
}
