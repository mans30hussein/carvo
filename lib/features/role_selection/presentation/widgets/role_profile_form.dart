import 'package:carvo/core/constants/app_string.dart';
import 'package:carvo/core/widgets/app_text_field.dart';
 import 'package:carvo/core/widgets/primary_button.dart';
import 'package:carvo/features/role_selection/presentation/widgets/location_address_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Required data" section: name / phone / (specialization) / address
/// fields plus the save button.
///
/// Field hints swap per [selectedRole], and the specialization field only
/// appears for mechanics. Controllers are owned by the parent screen so
/// their lifecycle (and disposal) stays with the state that created them.
class RoleProfileForm extends StatelessWidget {
  const RoleProfileForm({
    super.key,
    required this.selectedRole,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.specializationController,
    required this.isLoading,
    required this.onSave,
  });

  final String? selectedRole;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController specializationController;
  final bool isLoading;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final hints = _RoleFieldHints.forRole(selectedRole);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.requiredData,
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: nameController,
          label: hints.nameHint,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: phoneController,
          label: AppStrings.phoneContactLabel,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        if (selectedRole == 'mechanic') ...[
          AppTextField(
            controller: specializationController,
            label: AppStrings.specializationLabel,
            icon: Icons.handyman_outlined,
          ),
          const SizedBox(height: 16),
        ],
        LocationAddressField(
          controller: addressController,
          label: hints.addressHint,
          maxLines: 2,
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: AppStrings.saveAndContinue,
          isLoading: isLoading,
          onPressed: onSave,
        ),
      ],
    );
  }
}

/// Resolves the (name, address) hint pair for a given role.
class _RoleFieldHints {
  const _RoleFieldHints(this.nameHint, this.addressHint);

  final String nameHint;
  final String addressHint;

  factory _RoleFieldHints.forRole(String? role) {
    switch (role) {
      case 'vendor':
        return const _RoleFieldHints(
          AppStrings.nameHintVendor,
          AppStrings.addressHintVendor,
        );
      case 'mechanic':
        return const _RoleFieldHints(
          AppStrings.nameHintMechanic,
          AppStrings.addressHintMechanic,
        );
      case 'winch':
        return const _RoleFieldHints(
          AppStrings.nameHintWinch,
          AppStrings.addressHintWinch,
        );
      default:
        return const _RoleFieldHints(
          AppStrings.nameHintCustomer,
          AppStrings.addressHintCustomer,
        );
    }
  }
}