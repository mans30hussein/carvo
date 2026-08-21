import 'package:flutter/material.dart';

import '../../../../core/constants/app_string.dart';
import '../../../../core/app_style.dart';

 

/// Just the "no account? create one" prompt. Separated from
/// LoginFormSection because it's not part of the form — it's navigation,
/// and it's the piece most likely to change (e.g. becomes a Row with two
/// TextButtons if a "forgot password" link is added later).
class LoginFooterSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCreateAccountTap;

  const LoginFooterSection({
    super.key,
    required this.isLoading,
    required this.onCreateAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onCreateAccountTap,
      child: Text(AppStrings.noAccountPrompt, style: AppStyles.linkText),
    );
  }
}
