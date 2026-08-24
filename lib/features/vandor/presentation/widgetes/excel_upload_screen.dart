import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:file_picker/file_picker.dart';
 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/user_model.dart';

class ExcelUploadScreen extends StatefulWidget {
  final UserModel user;

  const ExcelUploadScreen({super.key, required this.user});

  @override
  State<ExcelUploadScreen> createState() => _ExcelUploadScreenState();
}

class _ExcelUploadScreenState extends State<ExcelUploadScreen> {
  bool _isLoading = false;

  Future<void> _pickAndUploadExcel() async {
  // اختيار ملف Excel
  final List<PlatformFile> result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx', 'pdf'],
    allowMultiple: false,
  );

  if (result.isEmpty) {
    _showSnackBar(
      'تم إلغاء اختيار الملف',
      Colors.orange,
    );
    return;
  }

  final PlatformFile file = result.first;

  if (!mounted) return;

  setState(() {
    _isLoading = true;
  });

  try {
    // قراءة الملف إلى Uint8List
    final Uint8List fileBytes = await file.readAsBytes();

    final String fileName = file.name;

    // Cloudinary
    final cloudinary = CloudinaryPublic(
      'dex177xix',
      'carvo_flutter',
      cache: false,
    );

    final CloudinaryResponse response =
        await cloudinary.uploadFile(
      CloudinaryFile.fromBytesData(
        fileBytes,
        identifier: fileName,
        folder: 'excel_sheets',
      ),
    );

    final String excelUrl = response.secureUrl;

    // Firestore
    await FirebaseFirestore.instance
        .collection('excel_uploads')
        .add({
      'userId': widget.user.uid,
      'userName': widget.user.name,
      'shopName': widget.user.shopName ?? widget.user.name,
      'fileName': fileName,
      'fileUrl': excelUrl,
      'uploadedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    _showSnackBar(
      'تم رفع الملف وحفظه بنجاح 🎉',
      Colors.green,
    );
  } catch (e) {
    if (!mounted) return;

    _showSnackBar(
      'حدث خطأ أثناء الرفع: $e',
      Colors.red,
    );
  } finally {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }
}
 
  
  // دالة مساعدة لإظهار رسائل للمستخدم
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // للحفاظ على خلفية التطبيق إذا كانت متدرجة
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة تعبر عن ملفات الـ Excel
              const Icon(
                Icons.description_rounded,
                size: 80,
                color: Colors.greenAccent,
              ),
              const SizedBox(height: 16),
              Text(
                widget.user.shopName ?? widget.user.name,
                style: GoogleFonts.cairo(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'صفحة رفع ملفات Excel',
                style: GoogleFonts.cairo(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              
              // عرض مؤشر التحميل أثناء الرفع أو عرض زر الرفع
              _isLoading
                  ? const Column(
                      children: [
                        CircularProgressIndicator(color: Colors.greenAccent),
                        SizedBox(height: 12),
                        Text(
                          'جاري رفع الملف وحفظ البيانات...',
                          style: TextStyle(color: Colors.white70),
                        )
                      ],
                    )
                  : ElevatedButton.icon(
                      onPressed: _pickAndUploadExcel,
                      icon: const Icon(Icons.upload_file_rounded, color: Colors.black87),
                      label: Text(
                        'اختر ملف Excel لرفعه',
                        style: GoogleFonts.cairo(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

// import 'package:flutter/material.dart';

// class ExcelUploadScreen extends StatelessWidget {
//   const ExcelUploadScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Card(
//       child: Text("data"),
//     );
//   }
// }