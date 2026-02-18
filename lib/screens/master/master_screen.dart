import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../models/mitra.dart';
import '../../models/rekening.dart';
import '../../services/master_service.dart';
import '../../widgets/currency_text.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Data'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Produk'),
            Tab(text: 'Mitra'),
            Tab(text: 'Rekening'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _ProductsTab(),
          _MitraTab(),
          _RekeningTab(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }
}

// --- Products ---
class _ProductsTab extends StatefulWidget {
  const _ProductsTab();

  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  final _service = MasterService();
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _products = await _service.getProducts();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_products.isEmpty) return const Center(child: Text('Tidak ada produk'));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _products.length,
        itemBuilder: (_, i) {
          final p = _products[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: p.status == 'AKTIF'
                    ? AppTheme.successColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                child: Icon(Icons.inventory_2,
                    color: p.status == 'AKTIF' ? AppTheme.successColor : Colors.grey),
              ),
              title: Text(p.nama),
              subtitle: Text(
                'Jual: ${formatRupiah(p.rateJualDefault)}  •  Beli: ${formatRupiah(p.rateBuyDefault)}\n'
                'Kategori: ${p.categoryNama ?? '-'}  •  Status: ${p.status}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

// --- Mitra ---
class _MitraTab extends StatefulWidget {
  const _MitraTab();

  @override
  State<_MitraTab> createState() => _MitraTabState();
}

class _MitraTabState extends State<_MitraTab> {
  final _service = MasterService();
  List<Mitra> _mitra = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _mitra = await _service.getMitra();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_mitra.isEmpty) return const Center(child: Text('Tidak ada mitra'));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _mitra.length,
        itemBuilder: (_, i) {
          final m = _mitra[i];
          final types = <String>[];
          if (m.tipeReseller == 1) types.add('Reseller');
          if (m.tipeHost == 1) types.add('Host');
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.warningColor.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppTheme.warningColor),
              ),
              title: Text(m.nama),
              subtitle: Text(
                '${types.join(' • ')}  •  ${m.status}\n${m.kontak ?? '-'}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

// --- Rekening ---
class _RekeningTab extends StatefulWidget {
  const _RekeningTab();

  @override
  State<_RekeningTab> createState() => _RekeningTabState();
}

class _RekeningTabState extends State<_RekeningTab> {
  final _service = MasterService();
  List<Rekening> _rekening = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _rekening = await _service.getRekening();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_rekening.isEmpty) return const Center(child: Text('Tidak ada rekening'));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _rekening.length,
        itemBuilder: (_, i) {
          final r = _rekening[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.account_balance, color: AppTheme.primaryColor),
              ),
              title: Text(r.displayName),
              subtitle: Text('${r.kategoriNama}  •  ${r.noRekening}'),
              trailing: Text(
                formatRupiah(r.saldo),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: r.saldo >= 0 ? AppTheme.successColor : AppTheme.dangerColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
