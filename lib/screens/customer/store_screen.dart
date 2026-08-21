import 'package:carvo/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
 
class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: InputDecoration(
                hintText: "ابحث عن قطعة غيار أو علامة تجارية...",
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Live Products Stream from Firestore
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: FirestoreService.streamProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  List<ProductModel> products = snapshot.data ?? [];
                  if (_searchQuery.isNotEmpty) {
                    products = products.where((p) {
                      return p.name.toLowerCase().contains(_searchQuery) ||
                             p.brandName.toLowerCase().contains(_searchQuery) ||
                             p.category.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 60, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text("لا توجد منتجات متاحة حالياً", style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                child: Image.network(
                                  product.image,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.surface,
                                    child: const Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.brandName,
                                    style: GoogleFonts.cairo(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${product.finalPrice.toStringAsFixed(0)} ج.م",
                                        style: GoogleFonts.cairo(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 14),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("تمت إضافة ${product.name} إلى السلة", style: GoogleFonts.cairo()),
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add_shopping_cart_rounded, size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
