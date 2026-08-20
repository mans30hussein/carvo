import 'package:carvo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
 import '../../screens/customer/customer_home_screen.dart';
import '../../screens/vendor/vendor_dashboard_screen.dart';
import '../../screens/mechanic/mechanic_dashboard_screen.dart';
import '../../screens/winch/winch_dashboard_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = 'vendor'; // 'customer', 'vendor', 'mechanic', 'winch'

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    User? cu = AuthService.currentFirebaseUser;
    if (cu != null) {
      if (cu.displayName != null && cu.displayName!.isNotEmpty) {
        _nameController.text = cu.displayName!;
      }
      if (cu.phoneNumber != null && cu.phoneNumber!.isNotEmpty) {
        _phoneController.text = cu.phoneNumber!;
      }
    }
  }

  void _saveProfile() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String address = _addressController.text.trim();
    String spec = _specController.text.trim();

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("يرجى استكمال جميع الحقول المطلوبة", style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: AppColors.surface,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    User? cu = AuthService.currentFirebaseUser;
    String uid = cu != null ? cu.uid : 'user_${DateTime.now().millisecondsSinceEpoch}';
    String email = cu != null && cu.email != null ? cu.email! : '';

    UserModel userModel = UserModel(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      address: address,
      type: _selectedRole,
      shopName: _selectedRole == 'vendor' ? name : null,
      specialization: _selectedRole == 'mechanic' ? spec : null,
    );

    await AuthService.saveUserProfile(userModel);

    setState(() => _isLoading = false);

    if (!mounted) return;

    Widget destination;
    switch (_selectedRole) {
      case 'vendor':
        destination = VendorDashboardScreen(user: userModel);
        break;
      case 'mechanic':
        destination = MechanicDashboardScreen(user: userModel);
        break;
      case 'winch':
        destination = WinchDashboardScreen(user: userModel);
        break;
      case 'customer':
      default:
        destination = CustomerHomeScreen(user: userModel);
        break;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
  }

  Widget _buildRoleCard({
    required String roleKey,
    required String title,
    required IconData icon,
    required String subtitle,
  }) {
    bool isSelected = _selectedRole == roleKey;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = roleKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 34,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String nameHint = "الاسم بالكامل";
    String addressHint = "العنوان بالتفصيل (المحافظة، المدينة، الشارع)";

    if (_selectedRole == 'vendor') {
      nameHint = "اسم المحل أو الشركة";
      addressHint = "عنوان المحل / الشركة بالتفصيل";
    } else if (_selectedRole == 'mechanic') {
      nameHint = "اسم الورشة / الفني";
      addressHint = "عنوان الورشة بالتفصيل";
    } else if (_selectedRole == 'winch') {
      nameHint = "اسم السائق / الونش";
      addressHint = "نطاق التغطية والعنوان بالتفصيل";
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("استكمال الحساب", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "اختر نوع حسابك:",
                style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),

              // Row 1: Customer & Vendor
              Row(
                children: [
                  _buildRoleCard(
                    roleKey: 'customer',
                    title: "🚗 عميل",
                    subtitle: "طلب قطع وغيار وإنقاذ",
                    icon: Icons.directions_car_rounded,
                  ),
                  const SizedBox(width: 12),
                  _buildRoleCard(
                    roleKey: 'vendor',
                    title: "🏪 تاجر / محل",
                    subtitle: "بيع وإدارة قطع الغيار",
                    icon: Icons.storefront_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 2: Mechanic & Winch
              Row(
                children: [
                  _buildRoleCard(
                    roleKey: 'mechanic',
                    title: "🔧 ميكانيكي / ورشة",
                    subtitle: "استقبال أعطال وصيانة",
                    icon: Icons.build_rounded,
                  ),
                  const SizedBox(width: 12),
                  _buildRoleCard(
                    roleKey: 'winch',
                    title: "🛻 ونش إنقاذ",
                    subtitle: "سحب وطوارئ الطرق",
                    icon: Icons.local_shipping_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                "البيانات المطلوبة:",
                style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),

              // Dynamic Name / Shop Field
              TextField(
                controller: _nameController,
                style: GoogleFonts.cairo(color: Colors.white),
                decoration: InputDecoration(
                  labelText: nameHint,
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.cairo(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "رقم الهاتف للتواصل",
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              // Specialization (for Mechanic)
              if (_selectedRole == 'mechanic') ...[
                TextField(
                  controller: _specController,
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "التخصص (مثال: ميكانيكا عامة، كهرباء، عفشة...)",
                    prefixIcon: Icon(Icons.handyman_outlined, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Address Field
              TextField(
                controller: _addressController,
                maxLines: 2,
                style: GoogleFonts.cairo(color: Colors.white),
                decoration: InputDecoration(
                  labelText: addressHint,
                  prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 32),

              // Save & Continue Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "حفظ واستمرار",
                          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
