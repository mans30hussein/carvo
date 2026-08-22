import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
 import '../../../../core/app_style.dart';
import '../../../../core/routing/app_routes.dart';
 import '../maneger/login_cubit/login_state.dart';

 
void handleLoginStateChange(BuildContext context, LoginState state) {
  switch (state) {
    case LoginSuccess(:final profile) :

    
      if (profile != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard, arguments: profile);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
      }

    case LoginFailure(:final message) when message.isNotEmpty:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: AppStyles.snackBarText),
          backgroundColor: AppColors.surface,
        ),
      );

    case LoginIdle():
    case LoginLoading():
    case LoginFailure():
      break;
  }
}
