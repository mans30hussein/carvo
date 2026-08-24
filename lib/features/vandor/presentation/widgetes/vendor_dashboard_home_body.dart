import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/product_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/firestore_service.dart';
import 'empty_products_state.dart';
import 'product_list_item.dart';
import 'section_title.dart';
import 'vendor_header.dart';

class VendorDashboardHomeBody extends StatelessWidget {
  final UserModel user;

  const VendorDashboardHomeBody({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VendorHeader(user: user),
          const SizedBox(height: 24),
          const SectionTitle(title: 'منتجات متجرك المسجلة في carvo'),
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
                return const EmptyProductsState();
              }

              final vendorProducts = snapshot.data ?? [];

              if (vendorProducts.isEmpty) {
                return const EmptyProductsState();
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vendorProducts.length,
                itemBuilder: (context, index) {
                  final product = vendorProducts[index];
                  return ProductListItem(
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
