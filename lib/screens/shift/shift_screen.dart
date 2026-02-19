import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/shift.dart';
import '../../services/shift_service.dart';
import '../../widgets/currency_text.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final _shiftService = ShiftService();
  bool _loading = true;
  Map<String, dynamic>? _activeShiftData;
  Map<String, dynamic> _ringkasan = {};
  List<ShiftConfig> _shiftConfigs = [];
  List<ShiftPartner> _partners = [];

  // Start shift form
  String? _selectedShiftName;
  int? _selectedPartner;
  final _modalAwalCtrl = TextEditingController(text: '0');

  // Close shift form
  final _modalAkhirCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool get _hasActiveShift => _activeShiftData != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final resp = await _shiftService.getActiveShift();
      final rawShift = resp['shift'];
      _activeShiftData = rawShift is Map<String, dynamic> ? rawShift : null;
      final rawRing = resp['ringkasan'];
      _ringkasan = rawRing is Map<String, dynamic> ? rawRing : {};

      _shiftConfigs = await _shiftService.getShiftConfig();
      try {
        _partners = await _shiftService.getPartners();
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _startShift() async {
    if (_selectedShiftName == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih shift dulu')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _shiftService.startShift(
        shiftName: _selectedShiftName!,
        modalAwal: double.tryParse(_modalAwalCtrl.text) ?? 0,
        partnerUserId: _selectedPartner,
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Shift berhasil dibuka')));
      }
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _closeShift() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tutup Shift?'),
        content: const Text('Yakin ingin menutup shift ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Tutup Shift'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      await _shiftService.closeShift(
        notes: _notesCtrl.text.trim(),
        modalAkhir: double.tryParse(_modalAkhirCtrl.text),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Shift berhasil ditutup')));
      }
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Management'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _hasActiveShift ? _buildActiveShift() : _buildStartShift(),
            ),
    );
  }

  Widget _buildActiveShift() {
    final shift = _activeShiftData!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: AppTheme.successColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shift Aktif', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(shift['shift_name'] ?? '-',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('Mulai: ${shift['start_time'] ?? '-'}',
                          style: const TextStyle(color: Colors.white70)),
                      Text('Modal Awal: ${formatRupiah((shift['modal_awal'] ?? 0).toDouble())}',
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (_ringkasan.isNotEmpty) ...[
          Text('Ringkasan Transaksi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._ringkasan.entries.where((e) => e.value is Map<String, dynamic>).map((e) {
            final v = e.value as Map<String, dynamic>;
            final count = (v['count'] is num) ? v['count'] : 0;
            final total = (v['total_rupiah'] is num) ? (v['total_rupiah'] as num).toDouble() : 0.0;
            return Card(
              child: ListTile(
                title: Text(e.key.replaceAll('_', ' ')),
                subtitle: Text('$count transaksi'),
                trailing: Text(formatRupiah(total),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],

        Text('Tutup Shift', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _modalAkhirCtrl,
          decoration: const InputDecoration(labelText: 'Modal Akhir (opsional)', prefixText: 'Rp '),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesCtrl,
          decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _closeShift,
            icon: const Icon(Icons.stop_circle),
            label: const Text('Tutup Shift'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStartShift() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.grey.shade200,
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey, size: 40),
                SizedBox(width: 16),
                Text('Tidak ada shift aktif',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Buka Shift Baru', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          value: _selectedShiftName,
          decoration: const InputDecoration(labelText: 'Pilih Shift'),
          items: _shiftConfigs
              .map((s) => DropdownMenuItem(
                  value: s.nama, child: Text('${s.nama} (${s.jamMulai} - ${s.jamSelesai})')))
              .toList(),
          onChanged: (v) => setState(() => _selectedShiftName = v),
        ),
        const SizedBox(height: 16),

        if (_partners.isNotEmpty) ...[
          DropdownButtonFormField<int>(
            value: _selectedPartner,
            decoration: const InputDecoration(labelText: 'Partner (opsional)'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tanpa partner')),
              ..._partners.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nama))),
            ],
            onChanged: (v) => setState(() => _selectedPartner = v),
          ),
          const SizedBox(height: 16),
        ],

        TextField(
          controller: _modalAwalCtrl,
          decoration: const InputDecoration(labelText: 'Modal Awal', prefixText: 'Rp '),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _startShift,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Buka Shift'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _modalAwalCtrl.dispose();
    _modalAkhirCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
}
