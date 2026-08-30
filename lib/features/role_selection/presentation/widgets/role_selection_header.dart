import 'package:carvo/core/constants/app_string.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Section title shown above [RoleTypeSelector].
///
/// Purely presentational — no state, no callbacks.
class RoleSelectionHeader extends StatelessWidget {
  const RoleSelectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.chooseAccountType,
      style: GoogleFonts.cairo(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}