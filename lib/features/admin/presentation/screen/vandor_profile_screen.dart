import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/user_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../customer/data/model/product_model.dart';

class VendorProfileScreen extends StatefulWidget {
  final UserModel vendor;
  const VendorProfileScreen({super.key, required this.vendor});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  late bool _isBlocked;
  bool _isTogglingBlock = false;

  @override
  void initState() {
    super.initState();
    _isBlocked = widget.vendor.isBlocked;
  }

  Future<void> _toggleBlock() async {
    setState(() => _isTogglingBlock = true);
    try {
      await FirestoreService.setUserBlocked(widget.vendor.uid, !_isBlocked);
      if (mounted) setState(() => _isBlocked = !_isBlocked);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تحديث حالة التاجر: $e")),
      );
    } finally {
      if (mounted) setState(() => _isTogglingBlock = false);
    }
  }

  Future<void> _confirmDeleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text("حذف المنتج", style: GoogleFonts.cairo(color: Colors.white)),
        content: Text(
          "متأكد إنك عايز تحذف \"${product.name}\"؟ الإجراء ده لا يمكن التراجع عنه.",
          style: GoogleFonts.cairo(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("إلغاء", style: GoogleFonts.cairo(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("حذف", style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirestoreService.deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم حذف المنتج")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل حذف المنتج: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vendor;
    final title = v.shopName?.isNotEmpty == true ? v.shopName! : v.name;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ProductModel>>(
          stream: FirestoreService.streamVendorProducts(v.uid),
          builder: (context, snapshot) {
            final products = snapshot.data ?? [];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _vendorInfoCard(v, products.length),
                const SizedBox(height: 20),
                Text(
                  "منتجات التاجر (${products.length})",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (products.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      "التاجر ده لسه مضافش منتجات",
                      style: GoogleFonts.cairo(color: AppColors.textMuted),
                    ),
                  )
                else
                  ...products.map((p) => _productRow(p)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _vendorInfoCard(UserModel v, int productCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  v.shopName?.isNotEmpty == true ? v.shopName! : v.name,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (_isBlocked ? Colors.red : Colors.green).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isBlocked ? "محظور" : "نشط",
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _isBlocked ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoLine(Icons.person_outline, "المالك", v.name),
          _infoLine(Icons.phone_outlined, "الهاتف", v.phone),
          _infoLine(Icons.email_outlined, "البريد", v.email),
          if (v.address.isNotEmpty)
            _infoLine(Icons.location_on_outlined, "العنوان", v.address),
          _infoLine(Icons.inventory_2_outlined, "عدد المنتجات", "$productCount"),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTogglingBlock ? null : _toggleBlock,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isBlocked ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              icon: _isTogglingBlock
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(_isBlocked ? Icons.lock_open_rounded : Icons.block_rounded, size: 18),
              label: Text(
                _isBlocked ? "إلغاء الحظر" : "حظر التاجر",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productRow(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.image,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 48,
                height: 48,
                color: AppColors.surface,
                child: const Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "${product.finalPrice.toStringAsFixed(0)} ج.م",
                  style: GoogleFonts.cairo(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _confirmDeleteProduct(product),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}