class ActiveShift {
  final int id;
  final int? shiftLogId;
  final String shiftName;
  final String startTime;
  final double modalAwal;
  final String status;
  final int? partnerUserId;

  ActiveShift({
    required this.id,
    required this.shiftName,
    required this.startTime,
    this.shiftLogId,
    this.modalAwal = 0,
    this.status = 'active',
    this.partnerUserId,
  });

  factory ActiveShift.fromJson(Map<String, dynamic> json) => ActiveShift(
        id: json['id'] ?? 0,
        shiftLogId: json['shift_log_id'],
        shiftName: json['shift_name'] ?? '',
        startTime: json['start_time'] ?? '',
        modalAwal: (json['modal_awal'] ?? 0).toDouble(),
        status: json['status'] ?? 'active',
        partnerUserId: json['partner_user_id'],
      );
}

class ShiftConfig {
  final int id;
  final String nama;
  final String jamMulai;
  final String jamSelesai;

  ShiftConfig({
    required this.id,
    required this.nama,
    required this.jamMulai,
    required this.jamSelesai,
  });

  factory ShiftConfig.fromJson(Map<String, dynamic> json) => ShiftConfig(
        id: json['id'] ?? 0,
        nama: json['nama'] ?? '',
        jamMulai: json['jam_mulai'] ?? '',
        jamSelesai: json['jam_selesai'] ?? '',
      );
}

class ShiftPartner {
  final int id;
  final String nama;

  ShiftPartner({required this.id, required this.nama});

  factory ShiftPartner.fromJson(Map<String, dynamic> json) =>
      ShiftPartner(id: json['id'] ?? 0, nama: json['nama'] ?? '');
}

class ShiftHistory {
  final String shiftKey;
  final int? shiftNumber;
  final String waktuBuka;
  final String? waktuTutup;
  final String status;
  final List<String> adminNames;

  ShiftHistory({
    required this.shiftKey,
    this.shiftNumber,
    required this.waktuBuka,
    this.waktuTutup,
    required this.status,
    this.adminNames = const [],
  });

  factory ShiftHistory.fromJson(Map<String, dynamic> json) => ShiftHistory(
        shiftKey: json['shift_key'] ?? '',
        shiftNumber: json['shift_number'],
        waktuBuka: json['waktu_buka'] ?? '',
        waktuTutup: json['waktu_tutup'],
        status: json['status'] ?? '',
        adminNames: List<String>.from(json['admin_names'] ?? []),
      );
}

class StockDefault {
  final int id;
  final String nama;
  final double stockDefault;

  StockDefault({required this.id, required this.nama, required this.stockDefault});

  factory StockDefault.fromJson(Map<String, dynamic> json) => StockDefault(
        id: json['id'] ?? 0,
        nama: json['nama'] ?? '',
        stockDefault: (json['stock_default'] ?? 0).toDouble(),
      );
}
