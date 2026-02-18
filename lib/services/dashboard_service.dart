import '../models/dashboard.dart';
import '../models/rekening.dart';
import 'api_client.dart';

class DashboardService {
  final _api = ApiClient();

  Future<DashboardSummary> getSummary() async {
    final resp = await _api.get('/dashboard/summary');
    return DashboardSummary.fromJson(resp['data']);
  }

  Future<Map<String, dynamic>> getShiftSummary() async {
    final resp = await _api.get('/dashboard/shift-summary');
    return resp['data'] ?? {};
  }

  Future<List<Rekening>> getRekeningSummary() async {
    final resp = await _api.get('/dashboard/rekening-summary');
    final list = resp['data']?['rekening'] as List? ?? [];
    return list.map((e) => Rekening.fromJson(e)).toList();
  }
}
