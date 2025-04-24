import 'package:absensi_app/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final IconData? icon;
  final double iconSize;
  final Color? iconColor;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.icon,
    this.iconSize = 30,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        icon:
            icon != null
                ? Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? AppColors.darkGrey,
                )
                : const SizedBox.shrink(),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          backgroundColor: backgroundColor ?? AppColors.greenLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
