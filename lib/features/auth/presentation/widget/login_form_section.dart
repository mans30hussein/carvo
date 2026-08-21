import 'package:flutter/material.dart';

import '../../../../core/constants/app_string.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

/// Owns just the input fields and the submit action — no BLoC awareness,
/// no navigation, no listener logic. It receives everything it needs as
/// parameters and reports the submit tap upward via onSubmit.
class LoginFormSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onPressed;

  const LoginFormSection({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: emailController,
          label: AppStrings.emailLabel,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: passwordController,
          label: AppStrings.passwordLabel,
          icon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: AppStrings.loginButton,
          isLoading: isLoading,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
