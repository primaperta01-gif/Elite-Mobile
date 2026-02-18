/// API configuration — change baseUrl to your server's IP/domain.
class ApiConfig {
  // Ganti dengan IP/domain server Anda:
  //   - Development (emulator): http://10.0.2.2:5000/api/v1
  //   - Development (HP real, LAN): http://192.168.x.x:5000/api/v1
  //   - Production: https://yourdomain.com/api/v1
  static const String baseUrl = 'http://10.0.2.2:5000/api/v1';

  static const Duration timeout = Duration(seconds: 30);
}
