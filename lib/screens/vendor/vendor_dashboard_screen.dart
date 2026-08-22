import 'package:carvo/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import 'add_product_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  final UserModel user;

  const VendorDashboardScreen({super.key, required this.user});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _selectedIndex = 0;

  void _openAddProductScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(user: widget.user),
      ),
    );
  }

  void _handleLogout() {
    Navigator.pop(context);
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.user.shopName ?? widget.user.name,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
          ),
        ],
      ),
      bottomNavigationBar: _VendorBottomNavBar(
        selectedIndex: _selectedIndex,
        onAddProduct: _openAddProductScreen, // زرار منفصل، مش تبويب
        onTabSelected: _onNavTap,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DashboardHomeBody(user: widget.user),
          ExcelUploadScreen(user: widget.user),
          WalletScreen(user: widget.user),
        ],
      ),
    );
  }
}

/// المحتوى الأصلي بتاع الداشبورد (الهيدر + قائمة المنتجات) — اتشال هنا
/// عشان يبقى تبويب رقم 0 جوه الـ IndexedStack.
class _DashboardHomeBody extends StatelessWidget {
  final UserModel user;

  const _DashboardHomeBody({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VendorHeader(user: user),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'منتجات متجرك المسجلة في carvo'),
          const SizedBox(height: 12),
          StreamBuilder<List<ProductModel>>(
            stream: FirestoreService.streamVendorProducts(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (snapshot.hasError) {
                return const _EmptyProductsState();
              }

              final vendorProducts = snapshot.data ?? [];

              if (vendorProducts.isEmpty) {
                return const _EmptyProductsState();
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vendorProducts.length,
                itemBuilder: (context, index) {
                  final product = vendorProducts[index];
                  return _ProductListItem(
                    product: product,
                    onDelete: () => FirestoreService.deleteProduct(product.id),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VendorBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onAddProduct;
  final ValueChanged<int> onTabSelected;

  const _VendorBottomNavBar({
    required this.selectedIndex,
    required this.onAddProduct,
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
            _NavItem(
              icon: Icons.dashboard_rounded,
              label: 'الرئيسية',
              isSelected: selectedIndex == 0,
              onTap: () => onTabSelected(0),
            ),
            _NavItem(
              icon: Icons.add_box_rounded,
              label: 'إضافة منتج',
              isSelected: false, // زرار فتح شاشة، مش تبويب فعّال
              onTap: onAddProduct,
            ),
            _NavItem(
              icon: Icons.upload_file_rounded,
              label: 'رفع Excel',
              isSelected: selectedIndex == 1,
              onTap: () => onTabSelected(1),
            ),
            _NavItem(
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.cairo(fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorHeader extends StatelessWidget {
  final UserModel user;

  const _VendorHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1C0C), Color(0xFF1E1E1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لوحة تحكم التاجر 🏪',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user.address,
                  style: GoogleFonts.cairo(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

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

class _ProductListItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onDelete;

  const _ProductListItem({
    required this.product,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.image,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: AppColors.surface,
              child: const Icon(
                Icons.image_not_supported_rounded,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '${product.brandName} • ${product.category}',
          style: GoogleFonts.cairo(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${product.finalPrice.toStringAsFixed(0)} ج.م',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 15,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class ExcelUploadScreen extends StatelessWidget {
  const ExcelUploadScreen({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            user.shopName ?? user.name,
            style: GoogleFonts.cairo(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'صفحة رفع Excel',
            style: GoogleFonts.cairo(fontSize: 24, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            user.shopName ?? user.name,
            style: GoogleFonts.cairo(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'صفحة المحفظة',
            style: GoogleFonts.cairo(fontSize: 24, color: Colors.white),
          ),
        ],
      ),
    );
  }
}