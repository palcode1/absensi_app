import 'package:flutter/material.dart';
import 'package:absensi_app/utils/constants.dart';

class CustomAppBar extends StatelessWidget {
  final Widget? content;
  final bool centerTitle;

  const CustomAppBar({super.key, this.content, this.centerTitle = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.greenDark,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child:
            content ??
            Text(
              "Judul",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
      ),
    );
  }
}
