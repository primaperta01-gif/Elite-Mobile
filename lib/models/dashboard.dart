class DashboardSummary {
  final String appName;
  final int userId;
  final String userName;
  final String userRole;
  final Map<String, dynamic>? activeShift;
  final Map<String, dynamic>? currentShift;

  DashboardSummary({
    required this.appName,
    required this.userId,
    required this.userName,
    required this.userRole,
    this.activeShift,
    this.currentShift,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return DashboardSummary(
      appName: json['app_name'] ?? '',
      userId: user['id'] ?? 0,
      userName: user['nama'] ?? '',
      userRole: user['role'] ?? '',
      activeShift: json['active_shift'],
      currentShift: json['current_shift'],
    );
  }

  bool get hasActiveShift => activeShift != null;
}

class RingkasanItem {
  final String jenis;
  final int count;
  final double totalRupiah;

  RingkasanItem({
    required this.jenis,
    required this.count,
    required this.totalRupiah,
  });
}

class StockItem {
  final int productId;
  final String namaProduk;
  final double koinAwal;
  final double koinAkhir;
  final double terjual;

  StockItem({
    required this.productId,
    required this.namaProduk,
    required this.koinAwal,
    required this.koinAkhir,
    required this.terjual,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
        productId: json['product_id'] ?? 0,
        namaProduk: json['nama_produk'] ?? json['nama'] ?? '',
        koinAwal: (json['koin_awal'] ?? 0).toDouble(),
        koinAkhir: (json['koin_akhir'] ?? 0).toDouble(),
        terjual: (json['terjual'] ?? json['koin_terjual'] ?? 0).toDouble(),
      );
}
