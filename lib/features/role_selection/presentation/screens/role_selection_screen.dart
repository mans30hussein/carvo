import 'package:carvo/core/constants/app_colors.dart';
import 'package:carvo/core/constants/app_string.dart';
import 'package:carvo/core/depandency_injection/depandency_injection.dart';
import 'package:carvo/features/role_selection/presentation/cubit/role_selection_cubit.dart';
import 'package:carvo/features/role_selection/presentation/cubit/role_selection_state.dart';
import 'package:carvo/features/role_selection/presentation/widgets/role_profile_form.dart';
import 'package:carvo/features/role_selection/presentation/widgets/role_selection_header.dart';
import 'package:carvo/features/role_selection/presentation/widgets/role_selection_state_listener.dart';
 import 'package:carvo/features/role_selection/presentation/widgets/rolr_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              const RoleSelectionHeader(),
              const SizedBox(height: 12),

              // 2. Role type cards
              RoleTypeSelector(
                selectedRole: selectedRole,
                onRoleSelected: (role) =>
                    context.read<RoleSelectionCubit>().selectRole(role),
              ),
              const SizedBox(height: 28),

              // 3. Text fields + save button
              RoleProfileForm(
                selectedRole: selectedRole,
                nameController: _nameController,
                phoneController: _phoneController,
                addressController: _addressController,
                specializationController: _specController,
                isLoading: isLoading,
                onSave: _onSave,
              ),
            ],
          ),
        );
      },
    );
  }
}