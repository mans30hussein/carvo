import 'package:carvo/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/user_model.dart';
import '../../../../screens/vendor/add_product_screen.dart';
import '../widgetes/excel_upload_screen.dart';
import '../widgetes/vendor_bottom_nav_bar.dart';
 import '../widgetes/wallet_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  final UserModel user;

  const VendorDashboardScreen({super.key, required this.user});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _selectedIndex = 0;




  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  List<Widget> _buildScreens() {
    return [
      AddProductScreen(user: widget.user),
     ExcelUploadScreen(user: widget.user),
      WalletScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.redAccent),
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.roleSelection),
        ),
        title: Text(
          widget.user.shopName ?? widget.user.name,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout_rounded),
        //     onPressed: _handleLogout,
        //   ),
        // ],
      ),
      bottomNavigationBar: VendorBottomNavBar(
        selectedIndex: _selectedIndex,
        // onAddProduct: _openAddProductScreen,
        onTabSelected: _onNavTap,
      ),
      body: _buildScreens()[_selectedIndex],
    );
  }
}
