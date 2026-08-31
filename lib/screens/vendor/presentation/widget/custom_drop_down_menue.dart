import 'package:carvo/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
 
/// A styled dropdown used across the app's forms. Reuse this instead of
/// building a new `DropdownButtonFormField` in every screen.
class CustomDropdownField extends StatelessWidget {
  final String value;
  final String label;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.card,
      style: GoogleFonts.cairo(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: GoogleFonts.cairo()),
            ),
          )
          .toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}