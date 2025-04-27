import 'package:absensi_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:absensi_app/services/auth_service.dart';
import 'package:absensi_app/widgets/input_field.dart';
import 'package:absensi_app/widgets/custom_button.dart';
import 'package:absensi_app/utils/helper.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showErrorToast("Semua field harus diisi.");
      return;
    }

    if (!isValidEmail(email)) {
      showErrorToast("Format email tidak valid.");
      return;
    }

    final success = await AuthService.registerUser(name, email, password);
    if (success) {
      if (mounted) {
        showToast('Akun berhasil dibuat, silahkan login');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } else {
      if (mounted) {
        showErrorToast("Email sudah digunakan.");
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 90),
            const Text(
              'Sign Up !',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            const Text(
              'Isi data di bawah ini',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 40),
            const Text(
              "Nama",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            CustomTextField(controller: _nameController),
            const SizedBox(height: 6),
            const Text(
              "Email",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            CustomTextField(controller: _emailController),
            const SizedBox(height: 6),
            const Text(
              "Password",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            CustomTextField(controller: _passwordController, obscureText: true),
            const SizedBox(height: 20),
            CustomButton(label: "REGISTER", onPressed: _register),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text(
                  "Sudah punya akun? Login",
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
