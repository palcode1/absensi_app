import 'package:absensi_app/utils/constants.dart';
import 'package:absensi_app/widgets/custom_button.dart';
import 'package:absensi_app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:absensi_app/models/user_model.dart';
import 'package:absensi_app/services/db_service.dart';
import 'package:absensi_app/widgets/input_field.dart';
import 'package:absensi_app/utils/helper.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  Future<void> _saveChanges() async {
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty) {
      if (mounted) showErrorToast("Semua field harus diisi.");
      return;
    }
    if (!isValidEmail(newEmail)) {
      if (mounted) showErrorToast("Format email tidak valid.");
      return;
    }

    final updatedUser = UserModel(
      id: widget.user.id,
      uid: widget.user.uid,
      name: newName,
      email: newEmail,
      password: widget.user.password, // password tidak diubah
    );

    await DBService.updateUser(updatedUser);
    if (mounted) {
      showSuccessToast("Data berhasil diperbarui!");
      Navigator.pop(context, true); // kembali ke profile
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.yellowSoft,
      body: Column(
        children: [
          CustomAppBar(
            content: Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Nama',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  CustomTextField(controller: _nameController),
                  const SizedBox(height: 10),
                  Text(
                    'Email',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  CustomTextField(controller: _emailController),
                  const SizedBox(height: 20),
                  Center(
                    child: CustomButton(
                      icon: Icons.save,
                      label: "Simpan",
                      onPressed: _saveChanges,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
