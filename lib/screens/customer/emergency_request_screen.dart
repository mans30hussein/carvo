import 'package:carvo/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/emergency_model.dart';

class EmergencyRequestScreen extends StatefulWidget {
  final UserModel user;
  const EmergencyRequestScreen({Key? key, required this.user})
    : super(key: key);

  @override
  State<EmergencyRequestScreen> createState() => _EmergencyRequestScreenState();
}

class _EmergencyRequestScreenState extends State<EmergencyRequestScreen> {
  String _selectedType = 'winch'; // 'winch' or 'mechanic'
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isSending = false;

  void _sendEmergencyRequest() async {
    String loc = _locationController.text.trim();
    String desc = _descController.text.trim();

    if (loc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("يرجى إدخال موقعك الحالي", style: GoogleFonts.cairo()),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    String id = "em_${DateTime.now().millisecondsSinceEpoch}";
    EmergencyModel em = EmergencyModel(
      id: id,
      customerId: widget.user.uid,
      customerName: widget.user.name,
      customerPhone: widget.user.phone,
      type: _selectedType,
      locationAddress: loc,
      description: desc.isEmpty
          ? (_selectedType == 'winch'
                ? "طلب ونش إنقاذ وسحب"
                : "طلب ميكانيكي طوارئ")
          : desc,
    );

    await FirestoreService.createEmergencyRequest(em);

    setState(() {
      _isSending = false;
      _locationController.clear();
      _descController.clear();
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              "تم إرسال الاستغاثة بنجاح",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          "تم إرسال طلبك إلى أقرب ${_selectedType == 'winch' ? 'سائق ونش' : 'ميكانيكي'}، وسيتم التواصل معك هاتفياً فوراً.",
          style: GoogleFonts.cairo(color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "حسناً",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Alert Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sos_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "خدمة طوارئ الطرق السريعة",
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "طلب استغاثة فوري لأقرب ونش أو ميكانيكي",
                          style: GoogleFonts.cairo(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "نوع الخدمة المطلوبة:",
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = 'winch'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedType == 'winch'
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedType == 'winch'
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_shipping_rounded,
                            color: _selectedType == 'winch'
                                ? AppColors.primary
                                : AppColors.textMuted,
                            size: 32,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "🛻 ونش إنقاذ",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = 'mechanic'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedType == 'mechanic'
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedType == 'mechanic'
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.build_rounded,
                            color: _selectedType == 'mechanic'
                                ? AppColors.primary
                                : AppColors.textMuted,
                            size: 32,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "🔧 ميكانيكي طوارئ",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Location Input
            TextField(
              controller: _locationController,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "موقعك الحالي (الشارع، الطريق، المعلم المميز)",
                prefixIcon: Icon(
                  Icons.my_location_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description Input
            TextField(
              controller: _descController,
              maxLines: 3,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "وصف العطل أو الحالة (اختياري)",
                prefixIcon: Icon(Icons.notes_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendEmergencyRequest,
                icon: const Icon(Icons.send_rounded),
                label: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "إرسال طلب الاستغاثة الآن",
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
