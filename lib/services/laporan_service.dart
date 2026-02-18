import 'api_client.dart';

class LaporanService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> getPerShift(int shiftId) async {
    final resp = await _api.get('/laporan/per-shift', queryParams: {
      'shift_id': shiftId.toString(),
    });
    return resp['data'] ?? {};
  }

  Future<List<Map<String, dynamic>>> getShiftGroups() async {
    final resp = await _api.get('/laporan/shift-groups');
    return List<Map<String, dynamic>>.from(resp['data']?['shift_groups'] ?? []);
  }

  Future<Map<String, dynamic>> getShiftGroupDetail(String shiftKey) async {
    final resp = await _api.get('/laporan/shift-group-detail', queryParams: {
      'shift_key': shiftKey,
    });
    return resp['data'] ?? {};
  }

  Future<List<Map<String, dynamic>>> getSelisih() async {
    final resp = await _api.get('/laporan/selisih');
    return List<Map<String, dynamic>>.from(resp['data']?['selisih'] ?? []);
  }

  Future<Map<String, dynamic>> getAudit({
    String? dateFrom,
    String? dateTo,
    String? module,
    int limit = 100,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      if (module != null) 'module': module,
    };
    final resp = await _api.get('/laporan/audit', queryParams: params);
    return resp['data'] ?? {};
  }
}
