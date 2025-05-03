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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  Future<void> _showConfirmationDialog() async {
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

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Konfirmasi Perubahan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.greenDark,
              ),
            ),
            content: const Text(
              "Apakah Anda yakin ingin menyimpan perubahan ini?",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _saveChanges();
                },
                child: const Text(
                  "Konfirmasi",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
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

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    final updatedUser = UserModel(
      id: widget.user.id,
      uid: widget.user.uid,
      name: newName,
      email: newEmail,
      password: widget.user.password, // password tidak diubah
    );

    try {
      await DBService.updateUser(updatedUser);
      if (mounted) {
        showSuccessToast("Data berhasil diperbarui!");
        Navigator.pop(context, true); // kembali ke profile
      }
    } catch (e) {
      if (mounted) {
        showErrorToast("Gagal memperbarui data. Silakan coba lagi.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isEmail = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType:
                  isEmail ? TextInputType.emailAddress : TextInputType.text,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: InputBorder.none,
                hintText: isEmail ? "Enter your email" : "Enter your name",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(icon, color: AppColors.greenLight, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.yellowSoft,
      body: Column(
        children: [
          // App Bar
          const CustomAppBar(
            content: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Icon(Icons.edit, color: AppColors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // Profile Avatar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.greenLight.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.greenLight,
                        child: Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Form Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              "Informasi Pengguna",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.greenDark,
                              ),
                            ),
                          ),

                          _buildInputField(
                            "Nama",
                            _nameController,
                            Icons.person,
                          ),

                          _buildInputField(
                            "Email",
                            _emailController,
                            Icons.email,
                            isEmail: true,
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Save Button
                    InkWell(
                      onTap: _isLoading ? null : _showConfirmationDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.greenLight.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              const Icon(
                                Icons.save,
                                color: Colors.white,
                                size: 20,
                              ),
                            const SizedBox(width: 8),
                            const Text(
                              "Simpan Perubahan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cancel Button
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: Colors.grey,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Kembali",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
