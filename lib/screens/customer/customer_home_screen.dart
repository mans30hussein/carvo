import 'package:carvo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
 import '../../features/auth/presentation/screens/login_screen.dart';
import 'store_screen.dart';
import 'cart_screen.dart';
import 'emergency_request_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  final UserModel user;
  const CustomerHomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeView(),
      const StoreScreen(),
      const CartScreen(),
      EmergencyRequestScreen(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            Text("CarVo", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            onPressed: () async {
              await AuthService.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_rounded), label: "المتجر"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: "السلة"),
          BottomNavigationBarItem(icon: Icon(Icons.sos_rounded), label: "طوارئ وونش"),
        ],
      ),
    );
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C1E11), Color(0xFF1E1E1E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "أهلاً بك، ${widget.user.name} 🚗",
                  style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  "كل ما تحتاجه لسيارتك من قطع غيار، صيانة، وسحب طوارئ بين يديك.",
                  style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Services
          Text("الخدمات السريعة", style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildServiceCard(
                title: "طلب ونش إنقاذ",
                subtitle: "سحب سريع للطريق",
                icon: Icons.local_shipping_rounded,
                color: AppColors.primary,
                onTap: () => setState(() => _currentIndex = 3),
              ),
              const SizedBox(width: 12),
              _buildServiceCard(
                title: "ميكانيكي طوارئ",
                subtitle: "صيانة أينما كنت",
                icon: Icons.build_rounded,
                color: Colors.blueAccent,
                onTap: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildServiceCard(
                title: "متجر قطع الغيار",
                subtitle: "تصفح وشراء بأسعار مميزة",
                icon: Icons.shopping_bag_rounded,
                color: Colors.greenAccent,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(width: 12),
              _buildServiceCard(
                title: "سلة الطلبات",
                subtitle: "متابعة مشترياتك",
                icon: Icons.receipt_long_rounded,
                color: Colors.purpleAccent,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
              Text(subtitle, style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
