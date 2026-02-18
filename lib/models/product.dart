class Product {
  final int id;
  final int categoryId;
  final String nama;
  final String? deskripsi;
  final String? iconPath;
  final double rateJualDefault;
  final double rateBuyDefault;
  final String hostType;
  final bool directSupplier;
  final double stokAwal;
  final String status;
  final String? categoryNama;

  Product({
    required this.id,
    required this.categoryId,
    required this.nama,
    this.deskripsi,
    this.iconPath,
    this.rateJualDefault = 0,
    this.rateBuyDefault = 0,
    this.hostType = 'seller_coin',
    this.directSupplier = false,
    this.stokAwal = 0,
    this.status = 'AKTIF',
    this.categoryNama,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] ?? 0,
        categoryId: json['category_id'] ?? 0,
        nama: json['nama'] ?? '',
        deskripsi: json['deskripsi'],
        iconPath: json['icon_path'],
        rateJualDefault: (json['rate_jual_default'] ?? 0).toDouble(),
        rateBuyDefault: (json['rate_beli_default'] ?? 0).toDouble(),
        hostType: json['host_type'] ?? 'seller_coin',
        directSupplier: (json['direct_supplier'] ?? 0) == 1,
        stokAwal: (json['stok_awal'] ?? 0).toDouble(),
        status: json['status'] ?? 'AKTIF',
        categoryNama: json['category_nama'] ?? json['kategori_nama'],
      );
}

class ProductCategory {
  final int id;
  final String nama;

  ProductCategory({required this.id, required this.nama});

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      ProductCategory(id: json['id'] ?? 0, nama: json['nama'] ?? '');
}
