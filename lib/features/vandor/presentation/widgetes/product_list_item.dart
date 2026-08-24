import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/product_model.dart';

class ProductListItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onDelete;

  const ProductListItem({
    super.key,
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
