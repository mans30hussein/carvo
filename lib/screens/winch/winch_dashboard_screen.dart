import 'package:carvo/core/routing/app_routes.dart';
import 'package:carvo/services/auth_service.dart';
import 'package:carvo/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/emergency_model.dart';
 
import '../../features/auth/presentation/screens/login_screen.dart';

class WinchDashboardScreen extends StatefulWidget {
  final UserModel user;
  const WinchDashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<WinchDashboardScreen> createState() => _WinchDashboardScreenState();
}

class _WinchDashboardScreenState extends State<WinchDashboardScreen> {
  void _callCustomer(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
       // automaticallyImplyLeading: true,
        title: Text(widget.user.name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
             
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Winch Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C1F0E), Color(0xFF1E1E1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_shipping_rounded, color: AppColors.primary, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("لوحة تحكم ونش الإنقاذ 🛻", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                        Text("نطاق التغطية: ${widget.user.address}", style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text("طلبات سحب وإنقاذ السيارات الواردة:", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            // Live Stream of Winch Emergencies
            StreamBuilder<List<EmergencyModel>>(
              stream: FirestoreService.streamEmergencies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                final allEmergencies = snapshot.data ?? [];
                final winchRequests = allEmergencies.where((e) => e.type == 'winch').toList();

                if (winchRequests.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.success),
                        const SizedBox(height: 12),
                        Text("لا توجد طلبات سحب حالياً", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text("أنت متصل لاستقبال أي طلبات ونش قريبة على الطريق", textAlign: TextAlign.center, style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: winchRequests.length,
                  itemBuilder: (context, index) {
                    final em = winchRequests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(em.customerName, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: em.status == 'accepted' ? AppColors.success.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    em.status == 'accepted' ? "تم قبول المهمة" : "طلب إنقاذ جديد",
                                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: em.status == 'accepted' ? AppColors.success : AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
                                const SizedBox(width: 4),
                                Expanded(child: Text(em.locationAddress, style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 13))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("ملاحظات: ${em.description}", style: GoogleFonts.cairo(color: AppColors.textMuted, fontSize: 12)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _callCustomer(em.customerPhone),
                                    icon: const Icon(Icons.phone_rounded, size: 18),
                                    label: Text("اتصال بالعميل", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                  ),
                                ),
                                if (em.status != 'accepted') ...[
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => FirestoreService.updateEmergencyStatus(
                                      em.id,
                                      'accepted',
                                      providerId: widget.user.uid,
                                      providerName: widget.user.name,
                                    ),
                                    child: Text("قبول المهمة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
