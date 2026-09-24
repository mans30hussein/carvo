import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/app_style.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../services/firestore_service.dart';
import '../maneger/login_cubit/login_state.dart';

Future<void> handleLoginStateChange(BuildContext context, LoginState state) async {
  switch (state) {
    case LoginSuccess():
      // `profile` from the auth layer isn't the Firestore UserModel
      // (it may not even carry a `type`), so ask Firestore directly
      // which is the single source of truth for role routing.
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userProfile = await FirestoreService.getUserProfile(uid);
      if (!context.mounted) return;

      if (userProfile == null) {
        // No 'users' doc yet — first login, role never chosen.
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.roleSelection,
          (route) => false,
        );
      } else {
        // Role already on file — skip role selection entirely and
        // clear the stack so back/logout-login can't land on it.
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
          arguments: userProfile,
        );
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