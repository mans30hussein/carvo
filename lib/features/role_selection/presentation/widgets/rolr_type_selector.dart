import 'package:carvo/core/constants/app_string.dart';
import 'package:carvo/features/role_selection/presentation/widgets/role_card.dart';
import 'package:flutter/material.dart';

/// 2x2 grid of [RoleCard]s letting the user pick their account type:
/// customer, vendor, mechanic, or winch.
///
/// Stateless by design — [selectedRole] and [onRoleSelected] are driven
/// entirely by the parent (the cubit), so this widget just renders and
/// reports taps.
class RoleTypeSelector extends StatelessWidget {
  const RoleTypeSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  final String? selectedRole;
  final ValueChanged<String> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RoleCard(
                title: AppStrings.roleCustomerTitle,
                subtitle: AppStrings.roleCustomerSubtitle,
                icon: Icons.directions_car_rounded,
                isSelected: selectedRole == 'customer',
                onTap: () => onRoleSelected('customer'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RoleCard(
                title: AppStrings.roleVendorTitle,
                subtitle: AppStrings.roleVendorSubtitle,
                icon: Icons.storefront_rounded,
                isSelected: selectedRole == 'vendor',
                onTap: () => onRoleSelected('vendor'),
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
                onTap: () => onRoleSelected('mechanic'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RoleCard(
                title: AppStrings.roleWinchTitle,
                subtitle: AppStrings.roleWinchSubtitle,
                icon: Icons.local_shipping_rounded,
                isSelected: selectedRole == 'winch',
                onTap: () => onRoleSelected('winch'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}