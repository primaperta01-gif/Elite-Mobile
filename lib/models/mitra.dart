class Mitra {
  final int id;
  final String nama;
  final int tipeReseller;
  final int tipeHost;
  final String? kontak;
  final String status;
  final String? kategori;
  final int? productCount;

  Mitra({
    required this.id,
    required this.nama,
    this.tipeReseller = 0,
    this.tipeHost = 0,
    this.kontak,
    this.status = 'AKTIF',
    this.kategori,
    this.productCount,
  });

  factory Mitra.fromJson(Map<String, dynamic> json) => Mitra(
        id: json['id'] ?? 0,
        nama: json['nama'] ?? '',
        tipeReseller: json['tipe_reseller'] ?? 0,
        tipeHost: json['tipe_host'] ?? 0,
        kontak: json['kontak'],
        status: json['status'] ?? 'AKTIF',
        kategori: json['kategori'],
        productCount: json['product_count'],
      );
}

class Reseller {
  final int id;
  final String nama;

  Reseller({required this.id, required this.nama});

  factory Reseller.fromJson(Map<String, dynamic> json) =>
      Reseller(id: json['id'] ?? 0, nama: json['nama'] ?? '');
}
