import 'package:flutter/material.dart';
import '../../models/transaksi.dart';
import '../../models/product.dart';
import '../../models/mitra.dart';
import '../../models/rekening.dart';
import '../../services/transaksi_service.dart';
import '../../services/master_service.dart';
import '../../services/shift_service.dart';
import '../../widgets/currency_text.dart';

class TransaksiInputScreen extends StatefulWidget {
  final String jenisTransaksi;
  final String title;

  const TransaksiInputScreen({
    super.key,
    required this.jenisTransaksi,
    required this.title,
  });

  @override
  State<TransaksiInputScreen> createState() => _TransaksiInputScreenState();
}

class _TransaksiInputScreenState extends State<TransaksiInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trxService = TransaksiService();
  final _masterService = MasterService();
  final _shiftService = ShiftService();

  List<Product> _products = [];
  List<Reseller> _resellers = [];
  List<Rekening> _rekeningList = [];
  int? _activeShiftLogId;
  bool _loading = true;
  bool _submitting = false;

  // Form fields
  int? _productId;
  int? _resellerId;
  int? _rekeningId;
  final _jumlahCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _customerNameCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();
  final _idPlayerCtrl = TextEditingController();
  final _namaPenerimaCtrl = TextEditingController();
  String _customerType = 'CUSTOMER';
  String _metodeBayar = 'TRANSFER';
  String _statusPembayaran = 'LUNAS';

  bool get _isJualKoin => widget.jenisTransaksi == 'JUAL_KOIN';
  bool get _isBeliGift => widget.jenisTransaksi == 'BELI_GIFT';
  bool get _isReload => widget.jenisTransaksi == 'RELOAD_KOIN';
  bool get _isPelunasan => widget.jenisTransaksi == 'PELUNASAN_KASBON';
  bool get _isTransfer =>
      widget.jenisTransaksi == 'TRANSFER_KELUAR' || widget.jenisTransaksi == 'TRANSFER_MASUK';

  @override
  void initState() {
    super.initState();
    _loadDropdowns();
    _jumlahCtrl.addListener(_calcTotal);
    _rateCtrl.addListener(_calcTotal);
  }

  void _calcTotal() {
    final jumlah = double.tryParse(_jumlahCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;
    if (jumlah > 0 && rate > 0) {
      _totalCtrl.text = (jumlah * rate).toStringAsFixed(0);
    }
  }

  Future<void> _loadDropdowns() async {
    try {
      final shift = await _shiftService.getActiveShift();
      final shiftData = shift['shift'];
      _activeShiftLogId = shiftData?['shift_log_id'];

      _products = await _masterService.getProducts(status: 'AKTIF');
      _resellers = await _masterService.getResellers();
      _rekeningList = await _masterService.getRekening();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_activeShiftLogId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tidak ada shift aktif')));
      return;
    }

    setState(() => _submitting = true);
    try {
      final trx = Transaksi(
        shiftId: _activeShiftLogId!,
        jenisTransaksi: widget.jenisTransaksi,
        productId: _productId,
        resellerId: _resellerId,
        jumlah: double.tryParse(_jumlahCtrl.text),
        rate: double.tryParse(_rateCtrl.text),
        totalRupiah: double.tryParse(_totalCtrl.text) ?? 0,
        customerType: _customerType,
        customerName: _customerNameCtrl.text.trim(),
        noHandphone: _noHpCtrl.text.trim(),
        idPlayer: _idPlayerCtrl.text.trim(),
        namaPenerima: _namaPenerimaCtrl.text.trim(),
        metodeBayar: _metodeBayar,
        statusPembayaran: _statusPembayaran,
        rekeningId: _rekeningId,
      );

      await _trxService.create(trx);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Transaksi berhasil disimpan')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_activeShiftLogId == null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(child: Text('Tidak ada shift aktif. Buka shift dulu.')),
                        ],
                      ),
                    ),

                  // Product dropdown (for jual/beli/reload)
                  if (_isJualKoin || _isBeliGift || _isReload) ...[
                    DropdownButtonFormField<int>(
                      value: _productId,
                      decoration: const InputDecoration(labelText: 'Produk'),
                      items: _products
                          .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nama)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _productId = v);
                        if (v != null) {
                          final p = _products.firstWhere((p) => p.id == v);
                          _rateCtrl.text = _isBeliGift
                              ? p.rateBuyDefault.toStringAsFixed(0)
                              : p.rateJualDefault.toStringAsFixed(0);
                        }
                      },
                      validator: (v) => v == null ? 'Pilih produk' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Reseller dropdown (for jual_koin, pelunasan)
                  if (_isJualKoin || _isPelunasan) ...[
                    if (_isJualKoin)
                      DropdownButtonFormField<String>(
                        value: _customerType,
                        decoration: const InputDecoration(labelText: 'Tipe Customer'),
                        items: ['CUSTOMER', 'RESELLER']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(() => _customerType = v ?? 'CUSTOMER'),
                      ),
                    if (_isJualKoin) const SizedBox(height: 16),
                    if (_customerType == 'RESELLER' || _isPelunasan)
                      DropdownButtonFormField<int>(
                        value: _resellerId,
                        decoration: const InputDecoration(labelText: 'Mitra/Reseller'),
                        items: _resellers
                            .map((r) => DropdownMenuItem(value: r.id, child: Text(r.nama)))
                            .toList(),
                        onChanged: (v) => setState(() => _resellerId = v),
                      ),
                    if (_customerType == 'RESELLER' || _isPelunasan) const SizedBox(height: 16),
                  ],

                  // Customer name
                  if (_isJualKoin) ...[
                    TextFormField(
                      controller: _customerNameCtrl,
                      decoration: const InputDecoration(labelText: 'Nama Customer'),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Jumlah + Rate (not for transfer/pelunasan)
                  if (!_isTransfer && !_isPelunasan) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _jumlahCtrl,
                            decoration: const InputDecoration(labelText: 'Jumlah'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _rateCtrl,
                            decoration: const InputDecoration(labelText: 'Rate'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Total Rupiah
                  TextFormField(
                    controller: _totalCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Total Rupiah',
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (double.tryParse(v) == null) return 'Angka tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Metode Bayar
                  if (_isJualKoin || _isBeliGift) ...[
                    DropdownButtonFormField<String>(
                      value: _metodeBayar,
                      decoration: const InputDecoration(labelText: 'Metode Bayar'),
                      items: ['TRANSFER', 'KOIN', 'TUKAR_KOIN', 'GIFT_BACK']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t.replaceAll('_', ' '))))
                          .toList(),
                      onChanged: (v) => setState(() => _metodeBayar = v ?? 'TRANSFER'),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Status Pembayaran
                  if (_isJualKoin) ...[
                    DropdownButtonFormField<String>(
                      value: _statusPembayaran,
                      decoration: const InputDecoration(labelText: 'Status Pembayaran'),
                      items: ['LUNAS', 'KASBON', 'TRANSFER']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _statusPembayaran = v ?? 'LUNAS'),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Rekening (for transfer)
                  if (_isTransfer || _metodeBayar == 'TRANSFER') ...[
                    DropdownButtonFormField<int>(
                      value: _rekeningId,
                      decoration: const InputDecoration(labelText: 'Rekening'),
                      items: _rekeningList
                          .map((r) => DropdownMenuItem(value: r.id, child: Text(r.displayName)))
                          .toList(),
                      onChanged: (v) => setState(() => _rekeningId = v),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _submitting || _activeShiftLogId == null ? null : _submit,
                      icon: _submitting
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save),
                      label: Text(_submitting ? 'Menyimpan...' : 'Simpan Transaksi'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _jumlahCtrl.dispose();
    _rateCtrl.dispose();
    _totalCtrl.dispose();
    _customerNameCtrl.dispose();
    _noHpCtrl.dispose();
    _idPlayerCtrl.dispose();
    _namaPenerimaCtrl.dispose();
    super.dispose();
  }
}
