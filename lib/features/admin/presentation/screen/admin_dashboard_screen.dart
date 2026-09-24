import 'package:carvo/features/admin/presentation/screen/ordered_waiting_screen.dart';
import 'package:carvo/features/admin/presentation/screen/vandor_list_screen.dart';

import 'package:carvo/features/admin/presentation/widget/product_inreview_card.dart';
import 'package:carvo/services/auth_service.dart';
import 'package:carvo/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/user_model.dart';
import '../../../../models/order_model.dart';
import '../../../../models/emergency_model.dart';
import '../../../auth/presentation/screens/login_screen.dart';

enum AdminSection {
  shipping,
  excelFiles,
  productReview,
  merchantAccounts,
  blockList,
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminSection _selectedSection = AdminSection.shipping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatGrid(),
              const SizedBox(height: 16),
              _buildSectionPillBar(),
              const SizedBox(height: 16),
              _buildSectionBody(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.logout_rounded),
        onPressed: () async {
          await AuthService.signOut();
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "لوحة الأدمن",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.directions_car_filled_rounded,
            color: AppColors.primary,
          ),
        ],
      ),
      actions: [
        const Icon(Icons.shield_outlined, color: AppColors.primary),
        const SizedBox(width: 12),
        const Icon(Icons.person_outline_rounded),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "أدمن",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  // ---- Stat grid ----------------------------------------------------

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _shippingPendingCard(),
        productsInReviewCard(),
        _activeEmergenciesCard(),
        _merchantsCard(),
      ],
    );
  }

Widget _shippingPendingCard() {
  return StreamBuilder<List<OrderModel>>(
    stream: FirestoreService.streamOrders(),
    builder: (context, snapshot) {
      final count = (snapshot.data ?? [])
          .where((o) => o.shippingStatus == 'awaiting_shipment')
          .length;
      return StatCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ShippingPendingScreen()),
        ),
        icon: Icons.local_shipping_outlined,
        iconColor: Colors.blueAccent,
        count: count,
        label: "طلبات بانتظار الشحن",
      );
    },
  );
}

  Widget _activeEmergenciesCard() {
    // NOTE: FirestoreService.streamEmergencies() needs to exist and
    // return a Stream<List<EmergencyModel>> from the emergencies
    // collection. Add it alongside streamUsers/streamProducts/streamOrders
    // if it isn't there yet.
    return StreamBuilder<List<EmergencyModel>>(
      stream: FirestoreService.streamEmergencies(),
      builder: (context, snapshot) {
        final count = (snapshot.data ?? [])
            .where((e) => e.status == 'pending' || e.status == 'accepted')
            .length;
        return StatCard(
          onTap: () {
            print('Active emergencies count: $count'); // Debugging line
            // Navigate to the active emergencies screen
            // Navigator.pushNamed(context, '/activeEmergencies');
          },
          icon: Icons.shield_outlined,
          iconColor: Colors.pinkAccent,
          count: count,
          label: "طوارئ نشطة",
        );
      },
    );
  }

  Widget _merchantsCard() {
    return StreamBuilder<List<UserModel>>(
      stream: FirestoreService.streamUsers(),
      builder: (context, snapshot) {
        final count = (snapshot.data ?? [])
            .where((u) => u.type == 'vendor')
            .length;
        return StatCard(
          // Tapping the "التجار" card now navigates to the vendors
          // list screen instead of just printing the count.
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VendorsListScreen()),
            );
          },
          icon: Icons.people_alt_outlined,
          iconColor: Colors.greenAccent,
          count: count,
          label: "التجار",
        );
      },
    );
  }

  // ---- Section pill bar ----------------------------------------------

  Widget _buildSectionPillBar() {
    final pills = <_PillDef>[
      _PillDef(
        AdminSection.shipping,
        "الشحن والفواتير",
        Icons.local_shipping_outlined,
      ),
      _PillDef(
        AdminSection.excelFiles,
        "ملفات Excel",
        Icons.description_outlined,
      ),
      _PillDef(
        AdminSection.productReview,
        "مراجعة المنتجات",
        Icons.inventory_2_outlined,
      ),
      _PillDef(
        AdminSection.merchantAccounts,
        "حسابات التجار",
        Icons.credit_card_outlined,
      ),
      _PillDef(AdminSection.blockList, "الحظر", Icons.block_outlined),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pills.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final pill = pills[index];
          final isSelected = pill.section == _selectedSection;
          return ChoiceChip(
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedSection = pill.section),
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white10,
            showCheckmark: false,
            avatar: Icon(
              pill.icon,
              size: 16,
              color: isSelected ? Colors.black : Colors.white70,
            ),
            label: Text(
              pill.label,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.black : Colors.white70,
              ),
            ),
          );
        },
      ),
    );
  }

  // ---- Section body ---------------------------------------------------

  Widget _buildSectionBody() {
    switch (_selectedSection) {
      case AdminSection.shipping:
        return _buildShippingSection();
      case AdminSection.excelFiles:
        return const _ComingSoonSection(label: "ملفات Excel");
      case AdminSection.productReview:
        return const _ComingSoonSection(label: "مراجعة المنتجات");
      case AdminSection.merchantAccounts:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const VendorsSectionBody(),
        );
      case AdminSection.blockList:
        return const _ComingSoonSection(label: "الحظر");
    }
  }

  Widget _buildShippingSection() {
    return StreamBuilder<List<OrderModel>>(
      stream: FirestoreService.streamOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final pending = (snapshot.data ?? [])
            .where((o) => o.shippingStatus == 'awaiting_shipment')
            .toList();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.local_shipping_outlined, color: AppColors.primary),
                  Text(
                    "طلبات بانتظار الشحن (${pending.length})",
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (pending.isEmpty)
                const _EmptyState(message: "لا توجد طلبات بانتظار الشحن")
              else
                ...pending.map(
                  (o) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "العميل: ${o.customerName}",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "الهاتف: ${o.customerPhone} • العنوان: ${o.customerAddress}",
                            style: GoogleFonts.cairo(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "إجمالي المبلغ: ${o.totalAmount.toStringAsFixed(0)} ج.م",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PillDef {
  final AdminSection section;
  final String label;
  final IconData icon;
  _PillDef(this.section, this.label, this.icon);
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final String label;
  final void Function()? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const Spacer(),
            Text(
              "$count",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 40,
            color: Colors.white24,
          ),
          const SizedBox(height: 8),
          Text(message, style: GoogleFonts.cairo(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ComingSoonSection extends StatelessWidget {
  final String label;
  const _ComingSoonSection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          "$label — قريباً",
          style: GoogleFonts.cairo(color: AppColors.textMuted),
        ),
      ),
    );
  }
}