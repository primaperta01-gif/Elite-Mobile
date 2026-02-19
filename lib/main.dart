import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/transaksi/transaksi_menu_screen.dart';
import 'screens/shift/shift_screen.dart';
import 'screens/laporan/laporan_screen.dart';
import 'screens/master/master_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const EliteApp());
}

class EliteApp extends StatelessWidget {
  const EliteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Elite Management',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            navigatorKey: auth.navigatorKey,
            home: const SplashScreen(),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/dashboard': (_) => const DashboardScreen(),
              '/transaksi': (_) => const TransaksiMenuScreen(),
              '/shift': (_) => const ShiftScreen(),
              '/laporan': (_) => const LaporanScreen(),
              '/master': (_) => const MasterScreen(),
              '/profile': (_) => const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    final loggedIn = await auth.tryAutoLogin();
    if (!mounted) return;
    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            Text('Elite Management',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
