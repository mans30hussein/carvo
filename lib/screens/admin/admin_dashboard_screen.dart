import 'package:carvo/services/auth_service.dart';
import 'package:carvo/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
 
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text("لوحة تحكم الأدمن 👑", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await AuthService.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.people_alt_rounded), text: "المستخدمين"),
            Tab(icon: Icon(Icons.inventory_2_rounded), text: "المنتجات"),
            Tab(icon: Icon(Icons.receipt_long_rounded), text: "الطلبات"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildProductsTab(),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return StreamBuilder<List<UserModel>>(
      stream: FirestoreService.streamUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return Center(child: Text("لا يوجد مستخدمين مسجلين", style: GoogleFonts.cairo(color: AppColors.textMuted)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            String roleText = "عميل";
            Color roleColor = Colors.blueAccent;

            if (user.type == 'vendor') {
              roleText = "تاجر";
              roleColor = AppColors.primary;
            } else if (user.type == 'mechanic') {
              roleText = "ميكانيكي";
              roleColor = Colors.purpleAccent;
            } else if (user.type == 'winch') {
              roleText = "ونش";
              roleColor = Colors.orangeAccent;
            } else if (user.type == 'admin') {
              roleText = "أدمن";
              roleColor = Colors.redAccent;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: roleColor.withOpacity(0.2),
                  child: Text(user.name.isNotEmpty ? user.name[0] : "U", style: GoogleFonts.cairo(color: roleColor, fontWeight: FontWeight.bold)),
                ),
                title: Text(user.name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text("${user.phone} • ${user.address}", style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: roleColor),
                  ),
                  child: Text(roleText, style: GoogleFonts.cairo(color: roleColor, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductsTab() {
    return StreamBuilder<List<ProductModel>>(
      stream: FirestoreService.streamProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return Center(child: Text("لا توجد منتجات مسجلة", style: GoogleFonts.cairo(color: AppColors.textMuted)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(p.image, width: 45, height: 45, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                ),
                title: Text(p.name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text("التاجر: ${p.vendorName} • ${p.finalPrice.toStringAsFixed(0)} ج.م", style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  onPressed: () => FirestoreService.deleteProduct(p.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return StreamBuilder<List<OrderModel>>(
      stream: FirestoreService.streamOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return Center(child: Text("لا توجد طلبات شراء مسجلة", style: GoogleFonts.cairo(color: AppColors.textMuted)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final o = orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("العميل: ${o.customerName}", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("الهاتف: ${o.customerPhone} • العنوان: ${o.customerAddress}", style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text("إجمالي المبلغ: ${o.totalAmount.toStringAsFixed(0)} ج.م", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
