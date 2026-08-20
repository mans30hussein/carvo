import 'package:carvo/features/auth/presentation/screens/login_screen.dart';
import 'package:carvo/features/auth/role_selection_screen.dart';
import 'package:carvo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
 import '../models/user_model.dart';
import 'customer/customer_home_screen.dart';
import 'vendor/vendor_dashboard_screen.dart';
import 'mechanic/mechanic_dashboard_screen.dart';
import 'winch/winch_dashboard_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();

    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    if (AuthService.currentFirebaseUser != null) {
      UserModel? profile = await AuthService.getCurrentUserProfile();
      if (profile != null) {
        _routeToDashboard(profile);
      } else {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        // );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
     }
  }

  void _routeToDashboard(UserModel user) {
    Widget destination;
    switch (user.type) {
      case 'admin':
        destination = const AdminDashboardScreen();
        break;
      case 'vendor':
        destination = VendorDashboardScreen(user: user);
        break;
      case 'mechanic':
        destination = MechanicDashboardScreen(user: user);
        break;
      case 'winch':
        destination = WinchDashboardScreen(user: user);
        break;
      case 'customer':
      default:
        destination = CustomerHomeScreen(user: user);
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "CarVo",
                style: GoogleFonts.cairo(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "خدمات السيارات وقطع الغيار والإنقاذ",
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              // const SizedBox(
              //   width: 28,
              //   height: 28,
              //   child: CircularProgressIndicator(
              //     strokeWidth: 3,
              //     valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
