import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
 import 'package:carvo/core/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
/// Tappable card for picking a product image from the camera or gallery.
///
/// This widget only handles picking + preview + showing an uploading
/// state — it does not know about Cloudinary or Firestore. The caller
/// (the cubit) owns the actual upload, so this card can be reused
/// anywhere an image needs to be picked, regardless of where it ends up
/// being stored.
class ProductImagePickerCard extends StatelessWidget {
  final Uint8List? previewBytes;
  final bool isUploading;
  final ValueChanged<ImageSource> onSourceSelected;
  final VoidCallback? onRemove;

  const ProductImagePickerCard({
    super.key,
    required this.previewBytes,
    required this.isUploading,
    required this.onSourceSelected,
    this.onRemove,
  });

  void _openSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  "التقاط صورة",
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSourceSelected(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  "اختيار من المعرض",
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSourceSelected(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : () => _openSourceSheet(context),
      child: Container(
        height: 160,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (previewBytes != null)
              Image.memory(previewBytes!, fit: BoxFit.cover)
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_a_photo_outlined,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "اختر صورة القطعة",
                      style: GoogleFonts.cairo(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            if (isUploading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "جاري رفع الصورة...",
                        style: GoogleFonts.cairo(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            if (previewBytes != null && !isUploading && onRemove != null)
              Positioned(
                top: 8,
                left: 8,
                child: GestureDetector(
                  onTap: onRemove,
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}