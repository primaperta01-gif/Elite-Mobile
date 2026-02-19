import '../models/transaksi.dart';
import 'api_client.dart';

class TransaksiService {
  final _api = ApiClient();

  Future<List<Transaksi>> listByShift(int shiftId) async {
    final resp = await _api.get('/transaksi/list', queryParams: {
      'shift_id': shiftId.toString(),
    });
    final rawData = resp['data'];
    final rawList = (rawData is Map<String, dynamic>) ? rawData['transaksi'] : null;
    final list = rawList is List ? rawList : [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => Transaksi.fromJson(e))
        .toList();
  }

  Future<int> create(Transaksi trx) async {
    final resp = await _api.post('/transaksi/create', body: trx.toCreateJson());
    return resp['data']?['transaksi_id'] ?? 0;
  }

  Future<void> deleteById(int id) async {
    await _api.delete('/transaksi/delete/$id');
  }

  Future<Map<String, dynamic>> getGlobal({
    int days = 30,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, String>{
      'days': days.toString(),
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
    };
    final resp = await _api.get('/transaksi/global', queryParams: params);
    final data = resp['data'];
    return data is Map<String, dynamic> ? data : {};
  }
}
