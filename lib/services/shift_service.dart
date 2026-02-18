import '../models/shift.dart';
import 'api_client.dart';

class ShiftService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> getActiveShift() async {
    final resp = await _api.get('/shift/active');
    return resp['data'] ?? {};
  }

  Future<Map<String, dynamic>> startShift({
    required String shiftName,
    double modalAwal = 0,
    int? partnerUserId,
    Map<int, double>? productStockAwal,
  }) async {
    final body = <String, dynamic>{
      'shift_name': shiftName,
      'modal_awal': modalAwal,
      if (partnerUserId != null) 'partner_user_id': partnerUserId,
      if (productStockAwal != null)
        'product_stock_awal':
            productStockAwal.map((k, v) => MapEntry(k.toString(), v)),
    };
    final resp = await _api.post('/shift/start', body: body);
    return resp['data'] ?? {};
  }

  Future<void> closeShift({String? notes, double? modalAkhir}) async {
    await _api.post('/shift/close', body: {
      if (notes != null) 'notes': notes,
      if (modalAkhir != null) 'modal_akhir': modalAkhir,
    });
  }

  Future<List<ShiftConfig>> getShiftConfig() async {
    final resp = await _api.get('/shift/config');
    final list = resp['data']?['shifts'] as List? ?? [];
    return list.map((e) => ShiftConfig.fromJson(e)).toList();
  }

  Future<List<ShiftPartner>> getPartners() async {
    final resp = await _api.get('/shift/partners');
    final list = resp['data']?['partners'] as List? ?? [];
    return list.map((e) => ShiftPartner.fromJson(e)).toList();
  }

  Future<List<ShiftHistory>> getHistory() async {
    final resp = await _api.get('/shift/history');
    final list = resp['data']?['shifts'] as List? ?? [];
    return list.map((e) => ShiftHistory.fromJson(e)).toList();
  }

  Future<List<StockDefault>> getStockDefaults() async {
    final resp = await _api.get('/shift/stock-defaults');
    final list = resp['data']?['products'] as List? ?? [];
    return list.map((e) => StockDefault.fromJson(e)).toList();
  }
}
