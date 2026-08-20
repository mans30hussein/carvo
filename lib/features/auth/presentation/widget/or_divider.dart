import 'package:carvo/core/app_string.dart';
import 'package:carvo/core/app_style.dart';
import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
 

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(AppStrings.orDivider, style: AppStyles.dividerText),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
