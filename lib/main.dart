import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/pasien/pasien_home_screen.dart';
import 'screens/nakes/nakes_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AsKes Lingkungan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/pasien': (_) => const PasienHomeScreen(),
        '/nakes': (_) => const NakesHomeScreen(),
        '/admin': (_) => const AdminHomeScreen(),
      },
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
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkSession();

    if (!mounted) return;

    if (authProvider.isLoggedIn) {
      final role = authProvider.role;
      if (role == 'pasien') {
        Navigator.pushReplacementNamed(context, '/pasien');
      } else if (role == 'nakes') {
        Navigator.pushReplacementNamed(context, '/nakes');
      } else if (role == 'admin_rt' || role == 'admin_rw') {
        Navigator.pushReplacementNamed(context, '/admin');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'AsKes Lingkungan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Memuat...',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}