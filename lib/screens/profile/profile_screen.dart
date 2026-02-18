import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                (user?.nama ?? '?')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(user?.nama ?? '-',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: (AppTheme.roleBadgeColors[user?.role] ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (user?.role ?? '').toUpperCase(),
                style: TextStyle(
                  color: AppTheme.roleBadgeColors[user?.role] ?? AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          _tile(context, 'UID', user?.uid ?? '-', Icons.badge),
          _tile(context, 'Kategori Kerja', user?.kategoriKerja ?? '-', Icons.work),
          _tile(context, 'Status', user?.status ?? '-', Icons.check_circle),
          _tile(context, 'Login Terakhir', user?.lastLogin ?? '-', Icons.schedule),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String label, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
