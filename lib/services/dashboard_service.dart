import '../models/dashboard.dart';
import '../models/rekening.dart';
import 'api_client.dart';

class DashboardService {
  final _api = ApiClient();

  Future<DashboardSummary> getSummary() async {
    final resp = await _api.get('/dashboard/summary');
    final data = resp['data'];
    return DashboardSummary.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<Map<String, dynamic>> getShiftSummary() async {
    final resp = await _api.get('/dashboard/shift-summary');
    final data = resp['data'];
    return data is Map<String, dynamic> ? data : {};
  }

  Future<List<Rekening>> getRekeningSummary() async {
    final resp = await _api.get('/dashboard/rekening-summary');
    final data = resp['data'];
    final list = (data is Map<String, dynamic> ? data['rekening'] : null);
    if (list is! List) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => Rekening.fromJson(e))
        .toList();
  }
}
