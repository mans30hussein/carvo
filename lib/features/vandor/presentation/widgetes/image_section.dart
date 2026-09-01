import 'package:carvo/features/vandor/presentation/widgetes/product_image_picker_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../maneger/add_product_cubit/add_product_cubit.dart';
import '../../maneger/add_product_cubit/add_product_state.dart';

/// Section 1: product image picker.
class ImageSection extends StatelessWidget {
  final AddProductState state;
  final AddProductCubit cubit;

  const ImageSection({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("صورة القطعة", style: GoogleFonts.cairo(color: Colors.white)),
        const SizedBox(height: 8),
        ProductImagePickerCard(
          previewBytes: state.pickedImageBytes,
          isUploading: state.imageStatus == ImageUploadStatus.uploading,
          onSourceSelected: cubit.pickAndUploadImage,
          onRemove: state.pickedImageBytes != null ? cubit.removeImage : null,
        ),
      ],
    );
  }
}