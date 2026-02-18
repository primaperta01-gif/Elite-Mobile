class Rekening {
  final int id;
  final int? kategoriId;
  final String kategoriNama;
  final String namaBankEwallet;
  final String namaRekening;
  final String noRekening;
  final double saldo;

  Rekening({
    required this.id,
    this.kategoriId,
    this.kategoriNama = '',
    this.namaBankEwallet = '',
    this.namaRekening = '',
    this.noRekening = '',
    this.saldo = 0,
  });

  factory Rekening.fromJson(Map<String, dynamic> json) => Rekening(
        id: json['id'] ?? 0,
        kategoriId: json['kategori_id'],
        kategoriNama: json['kategori_nama'] ?? '',
        namaBankEwallet: json['nama_bank_ewallet'] ?? '',
        namaRekening: json['nama_rekening'] ?? '',
        noRekening: json['no_rekening'] ?? '',
        saldo: (json['saldo'] ?? 0).toDouble(),
      );

  String get displayName =>
      namaBankEwallet.isNotEmpty ? '$namaBankEwallet - $namaRekening' : namaRekening;
}

class KategoriRekening {
  final int id;
  final String nama;

  KategoriRekening({required this.id, required this.nama});

  factory KategoriRekening.fromJson(Map<String, dynamic> json) =>
      KategoriRekening(id: json['id'] ?? 0, nama: json['nama'] ?? '');
}
