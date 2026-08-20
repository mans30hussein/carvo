import 'package:carvo/core/app_string.dart';
import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../core/app_style.dart';
 

class SocialSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SocialSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.g_mobiledata_rounded, size: 30, color: Colors.white),
      label: Text(AppStrings.googleSignIn, style: AppStyles.socialButtonText),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.borderLight),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
