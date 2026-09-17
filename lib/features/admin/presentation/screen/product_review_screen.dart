import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../customer/data/model/product_model.dart';
import '../../../../services/firestore_service.dart';

enum _Filter { pending, published, rejected }

class ProductsInReviewScreen extends StatefulWidget {
  const ProductsInReviewScreen({super.key});

  @override
  State<ProductsInReviewScreen> createState() => _ProductsInReviewScreenState();
}

class _ProductsInReviewScreenState extends State<ProductsInReviewScreen> {
  _Filter _filter = _Filter.pending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "مراجعة المنتجات",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ProductModel>>(
          stream: FirestoreService.streamProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "حدث خطأ أثناء تحميل المنتجات",
                  style: GoogleFonts.cairo(color: AppColors.textMuted),
                ),
              );
            }

            // Stable order as returned by Firestore — never reorder or
            // split on status change, so approving/rejecting one product
            // doesn't shift/rebuild the rest of the list.
            final all = snapshot.data ?? [];
            final pendingCount = all.where((p) => p.status == 'pending').length;
            final publishedCount = all.where((p) => p.status == 'published').length;
            final rejectedCount = all.where((p) => p.status == 'rejected').length;

            final visible = switch (_filter) {
              _Filter.pending => all.where((p) => p.status == 'pending').toList(),
              _Filter.published =>
                all.where((p) => p.status == 'published').toList(),
              _Filter.rejected => all.where((p) => p.status == 'rejected').toList(),
            };

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip("قيد المراجعة ($pendingCount)", _Filter.pending),
                        const SizedBox(width: 8),
                        _filterChip("تم النشر ($publishedCount)", _Filter.published),
                        const SizedBox(width: 8),
                        _filterChip("مرفوض ($rejectedCount)", _Filter.rejected),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? Center(
                          child: Text(
                            switch (_filter) {
                              _Filter.pending => "لا توجد منتجات قيد المراجعة",
                              _Filter.published => "لا توجد منتجات منشورة",
                              _Filter.rejected => "لا توجد منتجات مرفوضة",
                            },
                            style: GoogleFonts.cairo(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final product = visible[index];
                            // Keyed so a status change only repaints this
                            // one card, not the whole list.
                            return _ProductCard(
                              key: ValueKey(product.id),
                              product: product,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _filterChip(String label, _Filter value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white10,
      label: Text(
        label,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: isSelected ? Colors.black : Colors.white70,
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  const _ProductCard({super.key, required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isUpdating = false;

  Future<void> _setStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await FirestoreService.updateProductStatus(widget.product.id, newStatus);
      // No manual list update needed — streamProducts() re-fires, this
      // card is matched by its ValueKey(product.id). 'published' also
      // makes the product show in StoreScreen automatically; 'rejected'
      // (like 'pending') is filtered out of StoreScreen there.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تحديث حالة المنتج: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'published':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'published':
        return "منشور";
      case 'rejected':
        return "مرفوض";
      default:
        return "قيد المراجعة";
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final status = p.status;
    final badgeColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  p.image,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.broken_image_rounded,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _statusLabel(status),
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "البائع: ${p.vendorName}",
                      style: GoogleFonts.cairo(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      "${p.brandName} • ${p.category}",
                      style: GoogleFonts.cairo(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${p.finalPrice.toStringAsFixed(0)} ج.م",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _actionRow(status),
        ],
      ),
    );
  }

  Widget _actionRow(String status) {
    if (_isUpdating) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }

    // Pending: show both actions — approve or reject.
    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _setStatus('published'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: Text(
                "تم المراجعة",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _setStatus('rejected'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: Text(
                "رفض",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      );
    }

    // Published: allow pulling back to review if needed.
    if (status == 'published') {
      return Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () => _setStatus('pending'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.textMuted),
          icon: const Icon(Icons.undo_rounded, size: 18),
          label: Text(
            "إلغاء النشر",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      );
    }

    // Rejected: allow sending back to the review queue.
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () => _setStatus('pending'),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.textMuted),
        icon: const Icon(Icons.replay_rounded, size: 18),
        label: Text(
          "إعادة للمراجعة",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}