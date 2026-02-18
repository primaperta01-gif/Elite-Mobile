import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _uidController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = '';
  bool _obscure = true;

  static const _roles = [
    {'key': 'kasir', 'label': 'Kasir', 'icon': Icons.point_of_sale},
    {'key': 'master', 'label': 'Master', 'icon': Icons.admin_panel_settings},
    {'key': 'agency', 'label': 'Agency', 'icon': Icons.business},
    {'key': 'mitra', 'label': 'Mitra', 'icon': Icons.badge},
  ];

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final uid = _uidController.text.trim();
    final password = _passwordController.text.trim();
    if (uid.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('UID dan Password wajib diisi')),
      );
      return;
    }
    final success = await auth.login(
      uid,
      password,
      role: _selectedRole.isNotEmpty ? _selectedRole : null,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.store, size: 80, color: AppTheme.primaryColor),
                const SizedBox(height: 8),
                Text(
                  'Elite Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                const SizedBox(height: 32),

                // Role selector
                Text('Pilih Role', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _roles.map((r) {
                    final key = r['key'] as String;
                    final selected = _selectedRole == key;
                    final color = AppTheme.roleBadgeColors[key] ?? AppTheme.primaryColor;
                    return ChoiceChip(
                      avatar: Icon(r['icon'] as IconData, size: 18,
                          color: selected ? Colors.white : color),
                      label: Text(r['label'] as String),
                      selected: selected,
                      selectedColor: color,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : null,
                        fontWeight: selected ? FontWeight.bold : null,
                      ),
                      onSelected: (_) => setState(() {
                        _selectedRole = selected ? '' : key;
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // UID
                TextField(
                  controller: _uidController,
                  decoration: const InputDecoration(
                    labelText: 'UID',
                    prefixIcon: Icon(Icons.person),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 8),

                // Error message
                Consumer<AuthProvider>(
                  builder: (_, auth, __) {
                    if (auth.error == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        auth.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Login button
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: auth.loading ? null : _login,
                      child: auth.loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _uidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
