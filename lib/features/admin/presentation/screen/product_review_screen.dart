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
                              // Only the pending queue gets the edit
                              // action — that's the review workflow.
                              showEdit: _filter == _Filter.pending,
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
  final bool showEdit;
  const _ProductCard({super.key, required this.product, this.showEdit = false});

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

  Future<void> _openEditDialog() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EditProductDialog(product: widget.product),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم حفظ التعديلات")),
      );
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
                        if (widget.showEdit && !_isUpdating)
                          InkWell(
                            onTap: _openEditDialog,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
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

/// Full edit dialog — admin can change any field on the product and
/// save straight back to Firestore via FirestoreService.updateProductFields.
class _EditProductDialog extends StatefulWidget {
  final ProductModel product;
  const _EditProductDialog({required this.product});

  @override
  State<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _vendorCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _imageCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p.name);
    _vendorCtrl = TextEditingController(text: p.vendorName);
    _brandCtrl = TextEditingController(text: p.brandName);
    _categoryCtrl = TextEditingController(text: p.category);
    _priceCtrl = TextEditingController(text: p.finalPrice.toString());
    _imageCtrl = TextEditingController(text: p.image);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _vendorCtrl.dispose();
    _brandCtrl.dispose();
    _categoryCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = double.tryParse(_priceCtrl.text.trim());
    if (_nameCtrl.text.trim().isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تحقق من الاسم والسعر")),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await FirestoreService.updateProductFields(widget.product.id, {
        'name': _nameCtrl.text.trim(),
        'vendorName': _vendorCtrl.text.trim(),
        'brandName': _brandCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'finalPrice': price,
        'image': _imageCtrl.text.trim(),
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل حفظ التعديلات: $e")),
      );
      setState(() => _saving = false);
    }
  }

  Widget _field(String label, TextEditingController ctrl, {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "تعديل المنتج",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _field("اسم المنتج", _nameCtrl),
              _field("اسم البائع", _vendorCtrl),
              _field("العلامة التجارية", _brandCtrl),
              _field("التصنيف", _categoryCtrl),
              _field("السعر", _priceCtrl, type: const TextInputType.numberWithOptions(decimal: true)),
              _field("رابط الصورة", _imageCtrl),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                    child: Text(
                      "إلغاء",
                      style: GoogleFonts.cairo(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            "حفظ",
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}