import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-width primary action button with a built-in loading spinner state.
/// Reuse this for any "submit/save/publish" action in the app.
class PrimarySubmitButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const PrimarySubmitButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading ? const SizedBox.shrink() : Icon(icon),
        label: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}