import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.shopping_cart_outlined, size: 50, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text("سلة المشتريات فارغة", style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                "تصفح متجر قطع الغيار وأضف المنتجات المطلوبة لإتمام الشراء بسهولة.",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
