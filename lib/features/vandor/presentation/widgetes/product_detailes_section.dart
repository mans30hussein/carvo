import 'package:carvo/features/vandor/presentation/widgetes/custom_drop_down_menue.dart';
import 'package:carvo/features/vandor/presentation/widgetes/custom_text_field.dart';
import 'package:flutter/material.dart';
 import '../../maneger/add_product_cubit/add_product_cubit.dart';
import '../../maneger/add_product_cubit/add_product_state.dart';

/// Section 2: core product details — name, brand, price, category, part number.
class ProductDetailsSection extends StatelessWidget {
  final AddProductState state;
  final AddProductCubit cubit;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController partNumberController;

  const ProductDetailsSection({
    super.key,
    required this.state,
    required this.cubit,
    required this.nameController,
    required this.priceController,
    required this.partNumberController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: nameController,
          label: "اسم القطعة والمواصفات",
        ),
        const SizedBox(height: 16),

        CustomDropdownField(
          value: state.selectedBrand,
          label: "البراند",
          items: kProductBrands,
          onChanged: cubit.selectBrand,
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: priceController,
          label: "السعر (ج.م)",
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        CustomDropdownField(
          value: state.selectedCategory,
          label: "القسم / التصنيف",
          items: kProductCategories,
          onChanged: cubit.selectCategory,
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: partNumberController,
          label: "رقم القطعة",
        ),
      ],
    );
  }
}