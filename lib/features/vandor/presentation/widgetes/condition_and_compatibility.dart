import 'package:carvo/features/vandor/presentation/widgetes/condational_selector.dart';
import 'package:carvo/features/vandor/presentation/widgetes/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../maneger/add_product_cubit/add_product_cubit.dart';
import '../../maneger/add_product_cubit/add_product_state.dart';

/// Section 3: item condition + car compatibility (model / brand).
class ConditionAndCompatibilitySection extends StatelessWidget {
  final AddProductState state;
  final AddProductCubit cubit;
  final TextEditingController modelController;
  final TextEditingController brandMarkaController;

  const ConditionAndCompatibilitySection({
    super.key,
    required this.state,
    required this.cubit,
    required this.modelController,
    required this.brandMarkaController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("الحالة", style: GoogleFonts.cairo(color: Colors.white)),
        const SizedBox(height: 8),
        ConditionSelector(
          selected: state.condition,
          onChanged: cubit.selectCondition,
        ),
        const SizedBox(height: 16),

        Text("توافق السيارات", style: GoogleFonts.cairo(color: Colors.white)),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: modelController,
                label: "الموديل",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: brandMarkaController,
                label: "الماركة",
              ),
            ),
          ],
        ),
      ],
    );
  }
}