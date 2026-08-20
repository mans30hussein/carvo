import 'package:carvo/core/app_style.dart';
import 'package:flutter/material.dart';

 
/// Full-width action button that swaps to a spinner while loading and
/// disables itself — the original screen's button had neither behavior
/// (it was never even wired to an action).
class PrimaryAuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const PrimaryAuthButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label, style: AppStyles.buttonText),
      ),
    );
  }
}
