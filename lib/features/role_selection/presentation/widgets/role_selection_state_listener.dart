import 'package:flutter/material.dart';

import '../../../../core/app_style.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/role_router.dart';
import '../cubit/role_selection_state.dart';

void handleRoleSelectionStateChange(
  BuildContext context,
  RoleSelectionState state,
) {
  switch (state) {
    case RoleSelectionSuccess(:final user):
      // pushAndRemoveUntil (not pushReplacement) so the stack is fully
      // cleared regardless of how this screen was reached — role
      // selection can never be reached again via back button.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => RoleRouter.dashboardFor(user)),
        (route) => false,
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