import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'transaksi_input_screen.dart';

class TransaksiMenuScreen extends StatelessWidget {
  const TransaksiMenuScreen({super.key});

  static const _menus = [
    {'key': 'JUAL_KOIN', 'label': 'Penjualan Koin', 'icon': Icons.monetization_on, 'color': AppTheme.primaryColor},
    {'key': 'BELI_GIFT', 'label': 'Pembelian Gift', 'icon': Icons.card_giftcard, 'color': AppTheme.warningColor},
    {'key': 'RELOAD_KOIN', 'label': 'Reload Koin', 'icon': Icons.refresh, 'color': AppTheme.successColor},
    {'key': 'PELUNASAN_KASBON', 'label': 'Pelunasan Kasbon', 'icon': Icons.payment, 'color': Color(0xFF9C27B0)},
    {'key': 'TRANSFER_KELUAR', 'label': 'Transfer Keluar', 'icon': Icons.arrow_upward, 'color': AppTheme.dangerColor},
    {'key': 'TRANSFER_MASUK', 'label': 'Transfer Masuk', 'icon': Icons.arrow_downward, 'color': Color(0xFF00BCD4)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _menus.length,
          itemBuilder: (context, i) {
            final m = _menus[i];
            final color = m['color'] as Color;
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransaksiInputScreen(
                      jenisTransaksi: m['key'] as String,
                      title: m['label'] as String,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(m['icon'] as IconData, color: color, size: 32),
                    ),
                    const SizedBox(height: 10),
                    Text(m['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
