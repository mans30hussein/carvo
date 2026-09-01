import 'package:carvo/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
 
/// Condition of a listed product.
enum ProductCondition { newItem, used }

extension ProductConditionLabel on ProductCondition {
  String get arabicLabel {
    switch (this) {
      case ProductCondition.newItem:
        return "جديد";
      case ProductCondition.used:
        return "استيراد";
    }
  }
}

/// Two-option selector for product condition (new / used).
///
/// The original UI only rendered two static boxes with no selection state.
/// This widget makes the choice real and reusable anywhere a similar
/// toggle is needed.
class ConditionSelector extends StatelessWidget {
  final ProductCondition selected;
  final ValueChanged<ProductCondition> onChanged;

  const ConditionSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _option(ProductCondition.newItem)),
        const SizedBox(width: 12),
        Expanded(child: _option(ProductCondition.used)),
      ],
    );
  }

  Widget _option(ProductCondition value) {
    final bool isSelected = selected == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          value.arabicLabel,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}