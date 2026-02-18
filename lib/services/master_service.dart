import '../models/product.dart';
import '../models/mitra.dart';
import '../models/rekening.dart';
import 'api_client.dart';

class MasterService {
  final _api = ApiClient();

  // Products
  Future<List<Product>> getProducts({String? status}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    final resp = await _api.get('/master/products', queryParams: params.isNotEmpty ? params : null);
    final list = resp['data']?['products'] as List? ?? [];
    return list.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final resp = await _api.get('/master/products/$id');
    final data = resp['data']?['product'];
    return data != null ? Product.fromJson(data) : null;
  }

  Future<List<ProductCategory>> getProductCategories() async {
    final resp = await _api.get('/master/product-categories');
    final list = resp['data']?['categories'] as List? ?? [];
    return list.map((e) => ProductCategory.fromJson(e)).toList();
  }

  // Mitra
  Future<List<Mitra>> getMitra({String? tipe, String? search}) async {
    final params = <String, String>{};
    if (tipe != null) params['tipe'] = tipe;
    if (search != null) params['search'] = search;
    final resp = await _api.get('/master/mitra', queryParams: params.isNotEmpty ? params : null);
    final list = resp['data']?['mitra'] as List? ?? [];
    return list.map((e) => Mitra.fromJson(e)).toList();
  }

  Future<List<Reseller>> getResellers() async {
    final resp = await _api.get('/master/resellers');
    final list = resp['data']?['resellers'] as List? ?? [];
    return list.map((e) => Reseller.fromJson(e)).toList();
  }

  // Rekening
  Future<List<Rekening>> getRekening() async {
    final resp = await _api.get('/master/rekening');
    final list = resp['data']?['rekening'] as List? ?? [];
    return list.map((e) => Rekening.fromJson(e)).toList();
  }

  Future<List<KategoriRekening>> getKategoriRekening() async {
    final resp = await _api.get('/master/kategori-rekening');
    final list = resp['data']?['kategori'] as List? ?? [];
    return list.map((e) => KategoriRekening.fromJson(e)).toList();
  }

  // Kasbon
  Future<List<Map<String, dynamic>>> getKasbon() async {
    final resp = await _api.get('/master/kasbon');
    return List<Map<String, dynamic>>.from(resp['data']?['kasbon'] ?? []);
  }
}
