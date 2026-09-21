import 'package:carvo/features/vandor/maneger/vander_cubit/vander_cubit.dart';
import 'package:carvo/features/vandor/maneger/vander_cubit/vander_state.dart';
import 'package:carvo/models/user_model.dart';
import 'package:carvo/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductWaiting extends StatelessWidget {
  final UserModel user;
  const ProductWaiting({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VendorProductsCubit(vendorId: user.uid),
      child: BlocBuilder<VendorProductsCubit, VendorProductsState>(
        builder: (context, state) {
          if (state.status == VendorProductsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.products.isEmpty) {
            return Center(
              child: Text('لا توجد منتجات بعد', style: GoogleFonts.cairo()),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = state.products[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(product.image)),
                  title: Text(product.name,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  subtitle: Text('${product.finalPrice} ج.م', style: GoogleFonts.cairo()),
                  trailing: ProductStatusBadge(status: product.status),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class ProductStatusBadge extends StatelessWidget {
  final String status; // 'pending' or 'published'
  const ProductStatusBadge({super.key, required this.status});

  bool get _isPublished => status == 'published';

  @override
  Widget build(BuildContext context) {
    final Color color = _isPublished ? Colors.green : Colors.orange;
    final String label = _isPublished ? 'تم الموافقة' : 'في انتظار المراجعة';
    final IconData icon =
        _isPublished ? Icons.check_circle_rounded : Icons.hourglass_top_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
class ApproveProductButton extends StatelessWidget {
  final String productId;
  final String currentStatus;
  const ApproveProductButton({
    super.key,
    required this.productId,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPublished = currentStatus == 'published';

    return ElevatedButton.icon(
      onPressed: isPublished
          ? null
          : () async {
              await FirestoreService.updateProductStatus(productId, 'published');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تمت الموافقة على المنتج', style: GoogleFonts.cairo())),
                );
              }
            },
      icon: Icon(isPublished ? Icons.check_circle : Icons.check),
      label: Text(
        isPublished ? 'تمت الموافقة' : 'موافقة',
        style: GoogleFonts.cairo(),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPublished ? Colors.grey : Colors.green,
      ),
    );
  }
}