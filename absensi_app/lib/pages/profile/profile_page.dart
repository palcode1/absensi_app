import 'package:absensi_app/utils/constants.dart';
import 'package:absensi_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:absensi_app/models/user_model.dart';
import 'package:absensi_app/services/db_service.dart';
import 'package:absensi_app/services/shared_pref_service.dart';
import 'package:absensi_app/pages/auth/login_page.dart';
import 'package:absensi_app/pages/profile/edit_profile_page.dart';
import 'package:absensi_app/widgets/custom_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = await SharedPrefService.getUID();
    if (uid == null) return;

    final user = await DBService.getUserByUID(uid);
    if (user != null) {
      setState(() => _user = user);
    }
  }

  void _logout() async {
    await SharedPrefService.clearUID();
    if (!mounted) return;
    showSuccessToast('Berhasil Logout');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _user == null
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
          backgroundColor: AppColors.yellowSoft,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.greenLight,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _user!.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenDark,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _user!.email,
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 60),
                  CustomButton(
                    label: "Edit Profile",
                    icon: Icons.edit,
                    backgroundColor: AppColors.greenLight,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(user: _user!),
                        ),
                      );
                      if (result == true) {
                        _loadUser();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: "Logout",
                    icon: Icons.logout,
                    backgroundColor: AppColors.alert,
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
