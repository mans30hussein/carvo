import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class EmptyProductsState extends StatelessWidget {
  const EmptyProductsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'لم تقم بإضافة أي قطع غيار بعد',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "اضغط على زر 'إضافة قطعة غيار' لنشر منتجك فوراً للعملاء",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
