import 'package:absensi_app/pages/main_navigation/main_navigation_page.dart';
import 'package:absensi_app/services/shared_pref_service.dart';
import 'package:flutter/material.dart';
import 'package:absensi_app/utils/constants.dart';
import 'package:absensi_app/pages/auth/login_page.dart'; // atau home jika sudah login

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(Duration(seconds: 2));
    final uid = await SharedPrefService.getUID();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => uid != null ? MainNavigationPage() : LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.yellowSoft,
      body: Center(
        child: Image.asset(
          'assets/images/inoutin_logo.png',
          width: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
