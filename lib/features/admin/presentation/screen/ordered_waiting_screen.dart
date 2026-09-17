import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/order_model.dart';
import '../../../../services/firestore_service.dart';

enum _Filter { all, pending, shipped }

class ShippingPendingScreen extends StatefulWidget {
  const ShippingPendingScreen({super.key});

  @override
  State<ShippingPendingScreen> createState() => _ShippingPendingScreenState();
}

class _ShippingPendingScreenState extends State<ShippingPendingScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "حالة الشحن",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<OrderModel>>(
          stream: FirestoreService.streamOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "حدث خطأ أثناء تحميل الطلبات",
                  style: GoogleFonts.cairo(color: AppColors.textMuted),
                ),
              );
            }

            // Stable order as returned by streamOrders() (createdAt desc).
            // We NEVER reorder or split this list on status change — that
            // was what caused the whole list to visibly rebuild/jump.
            final all = snapshot.data ?? [];
            final pendingCount =
                all.where((o) => o.shippingStatus == 'awaiting_shipment').length;
            final shippedCount = all.where((o) => o.shippingStatus == 'shipped').length;

            final visible = switch (_filter) {
              _Filter.all => all,
              _Filter.pending =>
                all.where((o) => o.shippingStatus == 'awaiting_shipment').toList(),
              _Filter.shipped =>
                all.where((o) => o.shippingStatus == 'shipped').toList(),
            };

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      _filterChip("الكل (${all.length})", _Filter.all),
                      const SizedBox(width: 8),
                      _filterChip("قيد الانتظار ($pendingCount)", _Filter.pending),
                      const SizedBox(width: 8),
                      _filterChip("تم الشحن ($shippedCount)", _Filter.shipped),
                    ],
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? Center(
                          child: Text(
                            "لا توجد طلبات هنا",
                            style: GoogleFonts.cairo(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final order = visible[index];
                            // Key by order id: when a new snapshot arrives,
                            // Flutter matches this card by key and only
                            // repaints it if its own data changed — the
                            // rest of the list is left untouched.
                            return _OrderCard(key: ValueKey(order.id), order: order);
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

class _OrderCard extends StatefulWidget {
  final OrderModel order;
  const _OrderCard({super.key, required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _isUpdating = false;

  bool get _isShipped => widget.order.shippingStatus == 'shipped';

  Future<void> _toggleShipped() async {
    setState(() => _isUpdating = true);
    final newStatus = _isShipped ? 'awaiting_shipment' : 'shipped';
    try {
      await FirestoreService.updateOrderShippingStatus(widget.order.id, newStatus);
      // No manual state juggling needed — streamOrders() re-fires, this
      // card is matched by its ValueKey(order.id), and only its own
      // button/label repaint. Position in the list never changes because
      // we don't sort/split by status.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تحديث الحالة: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final shipped = _isShipped;

    return Card(
      margin: const EdgeInsets.only(bottom: 10, top: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "العميل: ${o.customerName}",
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (shipped ? Colors.green : Colors.orange).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    shipped ? "تم الشحن" : "قيد الانتظار",
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: shipped ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "الهاتف: ${o.customerPhone}",
              style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 12),
            ),
            Text(
              "العنوان: ${o.customerAddress}",
              style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              "إجمالي المبلغ: ${o.totalAmount.toStringAsFixed(0)} ج.م",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : _toggleShipped,
                style: ElevatedButton.styleFrom(
                  backgroundColor: shipped ? Colors.green : Colors.orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      (shipped ? Colors.green : Colors.orange).withOpacity(0.5),
                ),
                icon: _isUpdating
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        shipped
                            ? Icons.check_circle_outline
                            : Icons.local_shipping_outlined,
                        size: 18,
                      ),
                label: Text(
                  shipped ? "تم الشحن" : "في انتظار الشحن",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}