import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'nav_item.dart';

class VendorBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  //final VoidCallback onAddProduct;
  final ValueChanged<int> onTabSelected;

  const VendorBottomNavBar({
    super.key,
    required this.selectedIndex,
    // required this.onAddProduct,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NavItem(
              icon: Icons.add_box_rounded,
              label: 'إضافة منتج',
              isSelected: false,
              onTap: () => onTabSelected(0),
            ),
            NavItem(
              icon: Icons.upload_file_rounded,
              label: 'رفع Excel',
              isSelected: selectedIndex == 1,
              onTap: () => onTabSelected(1),
            ),
            NavItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'المحفظة',
              isSelected: selectedIndex == 2,
              onTap: () => onTabSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}
// NavItem(
//               icon: Icons.dashboard_rounded,
//               label: 'الرئيسية',
//               isSelected: selectedIndex == 0,
//               onTap: () => onTabSelected(0),
//             ),