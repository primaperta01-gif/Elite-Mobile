import '../models/transaksi.dart';
import 'api_client.dart';

class TransaksiService {
  final _api = ApiClient();

  Future<List<Transaksi>> listByShift(int shiftId) async {
    final resp = await _api.get('/transaksi/list', queryParams: {
      'shift_id': shiftId.toString(),
    });
    final list = resp['data']?['transaksi'] as List? ?? [];
    return list.map((e) => Transaksi.fromJson(e)).toList();
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
    return resp['data'] ?? {};
  }
}
