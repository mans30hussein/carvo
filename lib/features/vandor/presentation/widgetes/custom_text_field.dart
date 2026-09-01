import 'package:carvo/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
 
/// A styled text field used across the app's forms (Cairo font, primary
/// icon color, dark input style). Reuse this instead of building a new
/// `TextField` + `InputDecoration` combo in every screen.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.cairo(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
       // prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
      ),
    );
  }
}