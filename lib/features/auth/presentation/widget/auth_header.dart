import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/app_style.dart';
 
/// Icon circle + title + subtitle, used identically on both LoginScreen
/// and SignUpScreen with only the text differing.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.directions_car_filled_rounded,
            size: 50,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(title, style: AppStyles.screenTitle),
        Text(subtitle, style: AppStyles.screenSubtitle),
      ],
    );
  }
}
