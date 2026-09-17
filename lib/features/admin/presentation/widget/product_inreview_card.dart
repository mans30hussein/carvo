import 'package:carvo/features/admin/presentation/screen/admin_dashboard_screen.dart';
import 'package:carvo/features/admin/presentation/screen/product_review_screen.dart';
import 'package:carvo/features/customer/data/model/product_model.dart';
import 'package:carvo/services/firestore_service.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class productsInReviewCard extends StatelessWidget {
  const productsInReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProductModel>>(
      stream: FirestoreService.streamProducts(),
      builder: (context, snapshot) {
        final count = (snapshot.data ?? [])
            .where((p) => p.status == 'pending')
            .length;
        return StatCard(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductsInReviewScreen()),
          ),
          icon: Icons.inventory_2_outlined,
          iconColor: Colors.orangeAccent,
          count: count,
          label: "منتجات قيد المراجعة",
        );
      },
    );
  }
}