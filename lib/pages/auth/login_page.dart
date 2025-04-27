import 'package:absensi_app/pages/main_navigation/main_navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:absensi_app/services/auth_service.dart';
import 'package:absensi_app/utils/constants.dart';
import 'package:absensi_app/utils/helper.dart';
import 'package:absensi_app/widgets/input_field.dart';
import 'package:absensi_app/widgets/custom_button.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorToast("Email dan password wajib diisi.");
      return;
    }

    final success = await AuthService.loginUser(email, password);
    if (success) {
      if (mounted) {
        showSuccessToast("Halo, Selamat datang");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigationPage()),
        );
      }
    } else {
      if (mounted) {
        showErrorToast("Email atau password salah.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.yellowSoft,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.yellowSoft,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/absen_logo.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign In !',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            const Text(
              'Halo, Selamat Datang',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 40),
            const Text(
              "Email",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            CustomTextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 6),
            const Text(
              "Password",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            CustomTextField(controller: _passwordController, obscureText: true),
            const SizedBox(height: 20),
            CustomButton(label: 'LOGIN', onPressed: _login),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Belum punya akun? Register",
                  style: TextStyle(
                    color: AppColors.greenDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
