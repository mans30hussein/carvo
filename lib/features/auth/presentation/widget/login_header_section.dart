import 'package:flutter/material.dart';

 import '../../../../core/app_string.dart';
 import 'auth_header.dart';

/// Login-specific wrapper around the shared AuthHeader — keeps
/// LoginViewBody from knowing which strings belong to the login screen
/// vs. the sign-up screen.
class LoginHeaderSection extends StatelessWidget {
  const LoginHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthHeader(
      title: AppStrings.loginTitle,
      subtitle: AppStrings.loginSubtitle,
    );
  }
}
