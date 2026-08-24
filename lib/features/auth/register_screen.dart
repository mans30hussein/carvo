import 'package:carvo/features/role_selection/presentation/screens/role_selection_screen.dart';
import 'package:carvo/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
 import '../../models/user_model.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/customer/customer_home_screen.dart';
import '../vandor/presentation/screeens/vendor_dashboard_screen.dart';
import '../../screens/mechanic/mechanic_dashboard_screen.dart';
import '../../screens/winch/winch_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isOtpSent = false;
  String _generatedOtp = "";
  bool _isLoading = false;
  bool _isSignUpMode = false;

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showToast("يرجى ملء كافة الحقول");
      return;
    }

    // 1. فحص كود الأدمن السري كيمو مجدي
    if (AuthService.isAdminCredentials(email, password)) {
      UserModel admin = UserModel(
        uid: 'admin_kemo',
        name: 'الأدمن كيمو مجدي',
        email: 'kemo.magdy@carvo.com',
        phone: '01000000000',
        address: 'الإدارة المركزية',
        type: 'admin',
      );
      await AuthService.saveUserProfile(admin);
      if (!mounted) return;
      _showToast("مرحباً بك يا أدمن كيمو مجدي!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
      return;
    }

    // 2. نمط إنشاء الحساب عبر OTP العشوائي
    if (_isSignUpMode && !_isOtpSent) {
      setState(() => _isLoading = true);
      _generatedOtp = AuthService.generateOTP();
      setState(() {
        _isLoading = false;
        _isOtpSent = true;
      });
      _showOtpDialog(_generatedOtp);
      return;
    }

    // 3. تسجيل الدخول العادي بـ Firebase Auth
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _checkProfileAndNavigate();
    } catch (e) {
      setState(() => _isLoading = false);
      _showToast("بيانات الدخول غير صحيحة، أو أنشئ حساباً جديداً");
    }
  }

  void _verifyOtpAndRegister() async {
    String enteredOtp = _otpController.text.trim();
    if (enteredOtp != _generatedOtp) {
      _showToast("رمز التأكيد غير صحيح!");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showToast("حدث خطأ أثناء التسجيل: $e");
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    UserCredential? cred = await AuthService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (cred != null) {
      _checkProfileAndNavigate();
    }
  }

  void _checkProfileAndNavigate() async {
    UserModel? profile = await AuthService.getCurrentUserProfile();
    if (!mounted) return;

    if (profile != null) {
      Widget destination;
      switch (profile.type) {
        case 'admin':
          destination = const AdminDashboardScreen();
          break;
        case 'vendor':
          destination = VendorDashboardScreen(user: profile);
          break;
        case 'mechanic':
          destination = MechanicDashboardScreen(user: profile);
          break;
        case 'winch':
          destination = WinchDashboardScreen(user: profile);
          break;
        case 'customer':
        default:
          destination = CustomerHomeScreen(user: profile);
          break;
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
    }
  }

  void _showOtpDialog(String otp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.mark_email_read_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text("رمز التأكيد (OTP)", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("رمز التأكيد العشوائي لحسابك هو:", style: GoogleFonts.cairo(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Text(
                otp,
                style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 4),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("تم", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.cairo(color: Colors.white)),
        backgroundColor: AppColors.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isSignUpMode ? "إنشاء حساب جديد" : "تسجيل الدخول",
                  style: GoogleFonts.cairo(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "مرحباً بك في منصة CarVo لخدمات السيارات",
                  style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Email Input
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "البريد الإلكتروني",
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "كلمة المرور",
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),

                // OTP Input (when in OTP mode)
                if (_isOtpSent) ...[
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 20, letterSpacing: 4, color: AppColors.primary),
                    decoration: const InputDecoration(
                      labelText: "أدخل رمز التأكيد (6 أرقام)",
                      prefixIcon: Icon(Icons.security_rounded, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_isOtpSent ? _verifyOtpAndRegister : _handleLogin),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isOtpSent
                                ? "تأكيد وإنشاء الحساب"
                                : (_isSignUpMode ? "إرسال رمز التأكيد" : "دخول"),
                            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Toggle Login / SignUp
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUpMode = !_isSignUpMode;
                      _isOtpSent = false;
                    });
                  },
                  child: Text(
                    _isSignUpMode
                        ? "لديك حساب بالفعل؟ تسجيل الدخول"
                        : "ليس لديك حساب؟ إنشاء حساب جديد",
                    style: GoogleFonts.cairo(color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text("أو", style: GoogleFonts.cairo(color: AppColors.textMuted)),
                    ),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),
                const SizedBox(height: 16),

                // Google Sign In Button
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 30, color: Colors.white),
                  label: Text("تسجيل مباشر بحساب Google", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
