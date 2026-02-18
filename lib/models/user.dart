class User {
  final int id;
  final String nama;
  final String uid;
  final String role;
  final String kategoriKerja;
  final String status;
  final String? lastLogin;
  final List<String> permissions;

  User({
    required this.id,
    required this.nama,
    required this.uid,
    required this.role,
    this.kategoriKerja = '',
    this.status = 'AKTIF',
    this.lastLogin,
    this.permissions = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] ?? 0,
        nama: json['nama'] ?? '',
        uid: json['uid'] ?? '',
        role: json['role'] ?? '',
        kategoriKerja: json['kategori_kerja'] ?? '',
        status: json['status'] ?? 'AKTIF',
        lastLogin: json['last_login'],
        permissions: List<String>.from(json['permissions'] ?? []),
      );

  bool hasPermission(String perm) =>
      permissions.contains('*') || permissions.contains(perm);
}
