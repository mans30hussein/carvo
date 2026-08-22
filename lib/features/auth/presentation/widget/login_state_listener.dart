import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
 import '../../../../core/app_style.dart';
import '../../../../core/routing/app_routes.dart';
 import '../maneger/login_cubit/login_state.dart';

/// Every side effect a LoginState change should trigger: navigation and
/// SnackBars. Pulled out of the widget tree so LoginScreen's
/// BlocConsumer(listener: ...) is one line, and this logic can be read
/// (or unit tested with a mock BuildContext / navigator observer)
/// independently of any widget.
void handleLoginStateChange(BuildContext context, LoginState state) {
  switch (state) {
    case LoginSuccess(:final profile) :

    
      if (profile != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.roleSelection, arguments: profile);
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
