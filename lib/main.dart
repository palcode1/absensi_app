import 'package:flutter/material.dart';
import 'package:absensi_app/services/shared_pref_service.dart';
import 'package:absensi_app/pages/auth/login_page.dart';
import 'package:absensi_app/pages/splash_screen.dart';
import 'package:absensi_app/pages/home/dashboard_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:absensi_app/pages/main_navigation/main_navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Absensi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(), // Halaman pemutus awal
    );
  }
}

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  Future<bool> _checkLoginStatus() async {
    final uid = await SharedPrefService.getUID();
    return uid != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data == true
            ? const MainNavigationPage()
            : const LoginPage();
      },
    );
  }
}
