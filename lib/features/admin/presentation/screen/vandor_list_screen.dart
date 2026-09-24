import 'package:carvo/features/admin/presentation/screen/vandor_profile_screen.dart';
import 'package:carvo/models/user_model.dart';
import 'package:carvo/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class VendorsListScreen extends StatelessWidget {
  const VendorsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "التجار",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: VendorsSectionBody(),
        ),
      ),
    );
  }
}


/// The vendors list content, with no Scaffold/AppBar of its own so it
/// can be dropped straight into the "حسابات التجار" pill section on
/// the dashboard, or wrapped in a Scaffold for the full-page version
/// (see VendorsListScreen).
class VendorsSectionBody extends StatelessWidget {
  const VendorsSectionBody({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: FirestoreService.streamUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                "حدث خطأ أثناء تحميل التجار",
                style: GoogleFonts.cairo(color: AppColors.textMuted),
              ),
            ),
          );
        }

        final vendors =
            (snapshot.data ?? []).where((u) => u.type == 'vendor').toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "عدد التجار: ${vendors.length}",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            if (vendors.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "لا يوجد تجار مسجلين",
                  style: GoogleFonts.cairo(color: AppColors.textMuted),
                ),
              )
            else
              ...vendors.map(
                (v) => _VendorTile(key: ValueKey(v.uid), vendor: v),
              ),
          ],
        );
      },
    );
  }
}

class _VendorTile extends StatefulWidget {
  final UserModel vendor;
  const _VendorTile({super.key, required this.vendor});

  @override
  State<_VendorTile> createState() => _VendorTileState();
}

class _VendorTileState extends State<_VendorTile> {
  bool _isUpdating = false;

  Future<void> _toggleBlock() async {
    setState(() => _isUpdating = true);
    try {
      await FirestoreService.setUserBlocked(
        widget.vendor.uid,
        !widget.vendor.isBlocked,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تحديث حالة التاجر: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vendor;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => VendorProfileScreen(vendor: v)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surface,
              child: Icon(Icons.storefront_rounded, color: AppColors.textMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.shopName?.isNotEmpty == true ? v.shopName! : v.name,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    v.name,
                    style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  // Live product count for this vendor.
                  StreamBuilder<int>(
                    stream: FirestoreService.streamVendorProducts(v.uid)
                        .map((list) => list.length),
                    builder: (context, snap) {
                      final count = snap.data ?? 0;
                      return Text(
                        "عدد المنتجات: $count",
                        style: GoogleFonts.cairo(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _isUpdating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (v.isBlocked ? Colors.red : Colors.green).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          v.isBlocked ? "محظور" : "نشط",
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: v.isBlocked ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _toggleBlock,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            v.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                            size: 18,
                            color: v.isBlocked ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}