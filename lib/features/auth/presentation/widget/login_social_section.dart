import 'package:flutter/material.dart';

 
import 'or_divider.dart';
import 'social_sign_in_button.dart';

/// Groups the "or" divider with the Google button since they always
/// appear together — if Apple/Facebook sign-in is added later, this is
/// the one file that grows, not LoginViewBody.
class LoginSocialSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleTap;

  const LoginSocialSection({
    super.key,
    required this.isLoading,
    required this.onGoogleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OrDivider(),
        const SizedBox(height: 16),
        SocialSignInButton(onPressed: isLoading ? null : onGoogleTap),
      ],
    );
  }
}
