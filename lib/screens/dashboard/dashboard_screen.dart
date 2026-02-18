import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/dashboard_service.dart';
import '../../models/dashboard.dart';
import '../../models/rekening.dart';
import '../../widgets/info_card.dart';
import '../../widgets/currency_text.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dashService = DashboardService();
  DashboardSummary? _summary;
  Map<String, RingkasanItem> _ringkasan = {};
  List<StockItem> _stock = [];
  List<Rekening> _rekening = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      _summary = await _dashService.getSummary();

      final shiftData = await _dashService.getShiftSummary();
      final ringkasanMap = shiftData['ringkasan'] as Map<String, dynamic>? ?? {};
      _ringkasan = {};
      ringkasanMap.forEach((k, v) {
        _ringkasan[k] = RingkasanItem(
          jenis: k,
          count: v['count'] ?? 0,
          totalRupiah: (v['total_rupiah'] ?? 0).toDouble(),
        );
      });
      final stockList = shiftData['stock'] as List? ?? [];
      _stock = stockList.map((e) => StockItem.fromJson(e)).toList();

      _rekening = await _dashService.getRekeningSummary();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(_summary?.appName ?? 'Elite Management'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      drawer: _buildDrawer(context, auth),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // User greeting
                  Card(
                    color: AppTheme.primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white24,
                            radius: 24,
                            child: Text(
                              (user?.nama ?? '?')[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Halo, ${user?.nama ?? ''}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (user?.role ?? '').toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Shift status
                  if (_summary?.hasActiveShift == true) ...[
                    InfoCard(
                      title: 'Shift Aktif',
                      value: _summary!.activeShift!['shift_name'] ?? '-',
                      icon: Icons.access_time_filled,
                      color: AppTheme.successColor,
                      onTap: () => Navigator.pushNamed(context, '/shift'),
                    ),
                  ] else ...[
                    InfoCard(
                      title: 'Shift',
                      value: 'Tidak ada shift aktif',
                      icon: Icons.access_time,
                      color: Colors.grey,
                      onTap: () => Navigator.pushNamed(context, '/shift'),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Ringkasan Transaksi
                  if (_ringkasan.isNotEmpty) ...[
                    Text('Ringkasan Transaksi',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._ringkasan.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InfoCard(
                            title: e.key.replaceAll('_', ' '),
                            value: '${e.value.count}x  •  ${formatRupiah(e.value.totalRupiah)}',
                            icon: Icons.receipt_long,
                            color: AppTheme.primaryColor,
                          ),
                        )),
                    const SizedBox(height: 12),
                  ],

                  // Stock
                  if (_stock.isNotEmpty) ...[
                    Text('Stok Produk',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                          },
                          children: [
                            TableRow(children: [
                              Text('Produk', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
                              Text('Sisa', textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
                              Text('Terjual', textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
                            ]),
                            ..._stock.map((s) => TableRow(children: [
                                  Padding(padding: const EdgeInsets.only(top: 8), child: Text(s.namaProduk)),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(formatNumber(s.koinAkhir), textAlign: TextAlign.right)),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(formatNumber(s.terjual), textAlign: TextAlign.right,
                                          style: TextStyle(color: AppTheme.dangerColor))),
                                ])),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Rekening summary
                  if (_rekening.isNotEmpty) ...[
                    Text('Saldo Rekening',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._rekening.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InfoCard(
                            title: r.displayName,
                            value: formatRupiah(r.saldo),
                            icon: Icons.account_balance_wallet,
                            color: r.saldo >= 0 ? AppTheme.successColor : AppTheme.dangerColor,
                          ),
                        )),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider auth) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 28,
                  child: Text(
                    (auth.user?.nama ?? '?')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(auth.user?.nama ?? '', style: const TextStyle(color: Colors.white, fontSize: 16)),
                Text(auth.role.toUpperCase(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Input Transaksi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/transaksi');
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Shift'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/shift');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Laporan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/laporan');
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Master Data'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/master');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
