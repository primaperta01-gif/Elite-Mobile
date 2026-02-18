class Transaksi {
  final int? id;
  final int shiftId;
  final int? postedBy;
  final String jenisTransaksi;
  final int? productId;
  final int? resellerId;
  final double? jumlah;
  final double? rate;
  final double totalRupiah;
  final String? timestamp;
  final String customerType;
  final String customerName;
  final String noHandphone;
  final String idPlayer;
  final String namaPenerima;
  final String metodeBayar;
  final String statusPembayaran;
  final double kasbonAmount;
  final double pelunasanAmount;
  final int? rekeningId;
  final String rekeningPembayaran;
  final String buktiTransfer;
  final String statusInject;

  Transaksi({
    this.id,
    required this.shiftId,
    this.postedBy,
    required this.jenisTransaksi,
    this.productId,
    this.resellerId,
    this.jumlah,
    this.rate,
    required this.totalRupiah,
    this.timestamp,
    this.customerType = '',
    this.customerName = '',
    this.noHandphone = '',
    this.idPlayer = '',
    this.namaPenerima = '',
    this.metodeBayar = '',
    this.statusPembayaran = '',
    this.kasbonAmount = 0,
    this.pelunasanAmount = 0,
    this.rekeningId,
    this.rekeningPembayaran = '',
    this.buktiTransfer = '',
    this.statusInject = 'PENDING',
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) => Transaksi(
        id: json['id'],
        shiftId: json['shift_id'] ?? 0,
        postedBy: json['posted_by'],
        jenisTransaksi: json['jenis_transaksi'] ?? '',
        productId: json['product_id'],
        resellerId: json['reseller_id'],
        jumlah: json['jumlah']?.toDouble(),
        rate: json['rate']?.toDouble(),
        totalRupiah: (json['total_rupiah'] ?? 0).toDouble(),
        timestamp: json['timestamp'],
        customerType: json['customer_type'] ?? '',
        customerName: json['customer_name'] ?? '',
        noHandphone: json['no_handphone'] ?? '',
        idPlayer: json['id_player'] ?? '',
        namaPenerima: json['nama_penerima'] ?? '',
        metodeBayar: json['metode_bayar'] ?? '',
        statusPembayaran: json['status_pembayaran'] ?? '',
        kasbonAmount: (json['kasbon_amount'] ?? 0).toDouble(),
        pelunasanAmount: (json['pelunasan_amount'] ?? 0).toDouble(),
        rekeningId: json['rekening_id'],
        rekeningPembayaran: json['rekening_pembayaran'] ?? '',
        buktiTransfer: json['bukti_transfer'] ?? '',
        statusInject: json['status_inject'] ?? 'PENDING',
      );

  Map<String, dynamic> toCreateJson() => {
        'shift_id': shiftId,
        'jenis_transaksi': jenisTransaksi,
        if (productId != null) 'product_id': productId,
        if (resellerId != null) 'reseller_id': resellerId,
        if (jumlah != null) 'jumlah': jumlah,
        if (rate != null) 'rate': rate,
        'total_rupiah': totalRupiah,
        'customer_type': customerType,
        'customer_name': customerName,
        'no_handphone': noHandphone,
        'id_player': idPlayer,
        'nama_penerima': namaPenerima,
        'metode_bayar': metodeBayar,
        'status_pembayaran': statusPembayaran,
        'kasbon_amount': kasbonAmount,
        'pelunasan_amount': pelunasanAmount,
        if (rekeningId != null) 'rekening_id': rekeningId,
        'rekening_pembayaran': rekeningPembayaran,
        'bukti_transfer': buktiTransfer,
      };
}
