import 'package:flutter/material.dart';

import '../../../../core/app_style.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/user_model.dart';
import '../../../../screens/customer/customer_home_screen.dart';
import '../../../../screens/mechanic/mechanic_dashboard_screen.dart';
import '../../../../screens/vendor/vendor_dashboard_screen.dart';
import '../../../../screens/winch/winch_dashboard_screen.dart';
import '../maneger/role_selection_cubit/role_selection_state.dart';

void handleRoleSelectionStateChange(
  BuildContext context,
  RoleSelectionState state,
) {
  switch (state) {
    case RoleSelectionSuccess(:final user):
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => _destinationFor(user)),
      );

    case RoleSelectionFailure(:final message) when message.isNotEmpty:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: AppStyles.snackBarText),
          backgroundColor: AppColors.surface,
        ),
      );

    case RoleSelectionIdle():
    case RoleSelectionLoading():
    case RoleSelectionFailure():
      break;
  }
}

Widget _destinationFor(UserModel user) {
  switch (user.type) {
    case 'vendor':
      return VendorDashboardScreen(user: user);
    case 'mechanic':
      return MechanicDashboardScreen(user: user);
    case 'winch':
      return WinchDashboardScreen(user: user);
    case 'customer':
    default:
      return CustomerHomeScreen(user: user);
  }
}
