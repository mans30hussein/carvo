import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/user_model.dart';

class WalletScreen extends StatelessWidget {
  final UserModel user;

  const WalletScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            user.shopName ?? user.name,
            style: GoogleFonts.cairo(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'صفحة المحفظة',
            style: GoogleFonts.cairo(fontSize: 24, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
