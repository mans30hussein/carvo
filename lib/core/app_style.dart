
 
  
import 'package:carvo/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Every GoogleFonts.cairo(...) variant used across auth screens, named by
/// role instead of repeated inline. Previously the same style (e.g. white
/// bold 26px title) was retyped per screen — a design tweak meant editing
/// every occurrence. Now it's one line here.
class AppStyles {
  const AppStyles._();
 
  static TextStyle get screenTitle => GoogleFonts.cairo(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      );
 
  static TextStyle get screenSubtitle => GoogleFonts.cairo(
        fontSize: 14,
        color: AppColors.textSecondary,
      );
 
  static TextStyle get fieldText => GoogleFonts.cairo(color: Colors.white);
 
  static TextStyle get buttonText => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );
 
  static TextStyle get linkText => GoogleFonts.cairo(
        color: AppColors.primaryLight,
        fontWeight: FontWeight.w600,
      );
 
  static TextStyle get dividerText => GoogleFonts.cairo(color: AppColors.textMuted);
 
  static TextStyle get socialButtonText => GoogleFonts.cairo(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      );
 
  static TextStyle get snackBarText => GoogleFonts.cairo(color: Colors.white);
}
 
