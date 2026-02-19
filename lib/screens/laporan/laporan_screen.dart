import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/laporan_service.dart';
import '../../services/transaksi_service.dart';
import '../../models/transaksi.dart';
import '../../widgets/currency_text.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> with SingleTickerProviderStateMixin {
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
        title: const Text('Laporan'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Per Shift'),
            Tab(text: 'Global'),
            Tab(text: 'Selisih'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _ShiftGroupsTab(),
          _GlobalTab(),
          _SelisihTab(),
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

// --- Tab 1: Shift Groups ---
class _ShiftGroupsTab extends StatefulWidget {
  const _ShiftGroupsTab();

  @override
  State<_ShiftGroupsTab> createState() => _ShiftGroupsTabState();
}

class _ShiftGroupsTabState extends State<_ShiftGroupsTab> {
  final _service = LaporanService();
  List<Map<String, dynamic>> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _groups = await _service.getShiftGroups();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_groups.isEmpty) return const Center(child: Text('Tidak ada data shift'));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _groups.length,
        itemBuilder: (_, i) {
          final g = _groups[i];
          final status = g['status'] ?? '';
          final isOpen = status == 'OPEN';
          return Card(
            child: ListTile(
              leading: Icon(
                isOpen ? Icons.lock_open : Icons.lock,
                color: isOpen ? AppTheme.successColor : Colors.grey,
              ),
              title: Text('Shift ${g['shift_number'] ?? '-'}'),
              subtitle: Text('${g['waktu_buka'] ?? ''}\n${(g['admin_names'] is List ? (g['admin_names'] as List).join(', ') : '')}'),
              isThreeLine: true,
              trailing: Chip(
                label: Text(status, style: TextStyle(color: isOpen ? Colors.white : null, fontSize: 11)),
                backgroundColor: isOpen ? AppTheme.successColor : Colors.grey.shade200,
              ),
              onTap: () => _showDetail(g['shift_key'] ?? ''),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDetail(String shiftKey) async {
    if (shiftKey.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final data = await _service.getShiftGroupDetail(shiftKey);
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      final rawRingkasan = data['ringkasan'];
      final ringkasan = rawRingkasan is Map<String, dynamic> ? rawRingkasan : <String, dynamic>{};
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollCtrl) => ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20),
            children: [
              Text('Detail Shift $shiftKey',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...ringkasan.entries.where((e) => e.value is Map<String, dynamic>).map((e) {
                final v = e.value as Map<String, dynamic>;
                final count = (v['count'] is num) ? v['count'] : 0;
                final total = (v['total_rupiah'] is num) ? (v['total_rupiah'] as num).toDouble() : 0.0;
                return ListTile(
                  title: Text(e.key.replaceAll('_', ' ')),
                  subtitle: Text('$count transaksi'),
                  trailing: Text(formatRupiah(total),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              }),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}

// --- Tab 2: Global ---
class _GlobalTab extends StatefulWidget {
  const _GlobalTab();

  @override
  State<_GlobalTab> createState() => _GlobalTabState();
}

class _GlobalTabState extends State<_GlobalTab> {
  final _service = TransaksiService();
  List<Transaksi> _list = [];
  bool _loading = true;
  int _page = 1;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getGlobal(days: 30, page: _page, perPage: 50);
      final list = data['transaksi'] as List? ?? [];
      _list = list.map((e) => Transaksi.fromJson(e)).toList();
      _total = data['pagination']?['total'] ?? 0;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_list.isEmpty) return const Center(child: Text('Tidak ada transaksi'));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('Total: $_total transaksi (30 hari terakhir)',
              style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              itemCount: _list.length,
              itemBuilder: (_, i) {
                final t = _list[i];
                return ListTile(
                  dense: true,
                  title: Text(t.jenisTransaksi.replaceAll('_', ' ')),
                  subtitle: Text(t.timestamp ?? ''),
                  trailing: Text(formatRupiah(t.totalRupiah),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// --- Tab 3: Selisih ---
class _SelisihTab extends StatefulWidget {
  const _SelisihTab();

  @override
  State<_SelisihTab> createState() => _SelisihTabState();
}

class _SelisihTabState extends State<_SelisihTab> {
  final _service = LaporanService();
  List<Map<String, dynamic>> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _data = await _service.getSelisih();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_data.isEmpty) return const Center(child: Text('Tidak ada data selisih'));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _data.length,
        itemBuilder: (_, i) {
          final d = _data[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Shift ${d['shift_number'] ?? d['shift_log_id'] ?? '-'}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ...d.entries
                      .where((e) => e.key != 'shift_number' && e.key != 'shift_log_id')
                      .map((e) => Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 12))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
