import 'package:carvo/core/constants/app_colors.dart';
import 'package:carvo/core/constants/app_string.dart';
import 'package:carvo/core/depandency_injection/depandency_injection.dart';
import 'package:carvo/core/widgets/app_text_field.dart';
import 'package:carvo/core/widgets/primary_button.dart';
import 'package:carvo/features/role_selection/presentation/cubit/role_selection_cubit.dart';
import 'package:carvo/features/role_selection/presentation/cubit/role_selection_state.dart';
import 'package:carvo/features/role_selection/presentation/widgets/role_card.dart';
import 'package:carvo/features/role_selection/presentation/widgets/role_selection_state_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RoleSelectionCubit>()..loadPrefill(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            AppStrings.roleSelectionTitle,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: BlocListener<RoleSelectionCubit, RoleSelectionState>(
            listener: handleRoleSelectionStateChange,
            child: const _RoleSelectionView(),
          ),
        ),
      ),
    );
  }
}

class _RoleSelectionView extends StatefulWidget {
  const _RoleSelectionView();

  @override
  State<_RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<_RoleSelectionView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specController = TextEditingController();
  bool _didApplyPrefill = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specController.dispose();
    super.dispose();
  }

  void _applyPrefillIfNeeded(RoleSelectionState state) {
    if (_didApplyPrefill || state is! RoleSelectionIdle) return;
    if (state.prefillName != null) {
      _nameController.text = state.prefillName!;
    }
    if (state.prefillPhone != null) {
      _phoneController.text = state.prefillPhone!;
    }
    _didApplyPrefill = true;
  }

  void _onSave() {
    context.read<RoleSelectionCubit>().saveProfile(
          name: _nameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          specialization: _specController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoleSelectionCubit, RoleSelectionState>(
      listenWhen: (previous, current) =>
          current is RoleSelectionIdle &&
          (current.prefillName != null || current.prefillPhone != null),
      listener: (context, state) => _applyPrefillIfNeeded(state),
      builder: (context, state) {
        _applyPrefillIfNeeded(state);

        final selectedRole = state.selectedRole;
        final isLoading = state is RoleSelectionLoading;

        String nameHint = AppStrings.nameHintCustomer;
        String addressHint = AppStrings.addressHintCustomer;

        if (selectedRole == 'vendor') {
          nameHint = AppStrings.nameHintVendor;
          addressHint = AppStrings.addressHintVendor;
        } else if (selectedRole == 'mechanic') {
          nameHint = AppStrings.nameHintMechanic;
          addressHint = AppStrings.addressHintMechanic;
        } else if (selectedRole == 'winch') {
          nameHint = AppStrings.nameHintWinch;
          addressHint = AppStrings.addressHintWinch;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.chooseAccountType,
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: RoleCard(
                      title: AppStrings.roleCustomerTitle,
                      subtitle: AppStrings.roleCustomerSubtitle,
                      icon: Icons.directions_car_rounded,
                      isSelected: selectedRole == 'customer',
                      onTap: () => context
                          .read<RoleSelectionCubit>()
                          .selectRole('customer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RoleCard(
                      title: AppStrings.roleVendorTitle,
                      subtitle: AppStrings.roleVendorSubtitle,
                      icon: Icons.storefront_rounded,
                      isSelected: selectedRole == 'vendor',
                      onTap: () =>
                          context.read<RoleSelectionCubit>().selectRole('vendor'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: RoleCard(
                      title: AppStrings.roleMechanicTitle,
                      subtitle: AppStrings.roleMechanicSubtitle,
                      icon: Icons.build_rounded,
                      isSelected: selectedRole == 'mechanic',
                      onTap: () => context
                          .read<RoleSelectionCubit>()
                          .selectRole('mechanic'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RoleCard(
                      title: AppStrings.roleWinchTitle,
                      subtitle: AppStrings.roleWinchSubtitle,
                      icon: Icons.local_shipping_rounded,
                      isSelected: selectedRole == 'winch',
                      onTap: () =>
                          context.read<RoleSelectionCubit>().selectRole('winch'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

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
                controller: _nameController,
                label: nameHint,
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _phoneController,
                label: AppStrings.phoneContactLabel,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              if (selectedRole == 'mechanic') ...[
                AppTextField(
                  controller: _specController,
                  label: AppStrings.specializationLabel,
                  icon: Icons.handyman_outlined,
                ),
                const SizedBox(height: 16),
              ],

              AppTextField(
                controller: _addressController,
                label: addressHint,
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: AppStrings.saveAndContinue,
                isLoading: isLoading,
                onPressed: _onSave,
              ),
            ],
          ),
        );
      },
    );
  }
}
