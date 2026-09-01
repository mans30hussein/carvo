import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shows a styled, centered snackbar with Cairo font.
///
/// Reusable across any screen that needs to notify the user of a
/// success, error, or info message.
void showAppSnackBar(
  BuildContext context,
  String message,
  Color backgroundColor,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
    ),
  );
}