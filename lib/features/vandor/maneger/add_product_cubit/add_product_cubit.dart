import 'dart:typed_data';
import 'package:carvo/features/vandor/data/cloudinary_service.dart';
import 'package:carvo/features/vandor/presentation/widgetes/condational_selector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carvo/services/firestore_service.dart';
 import 'package:carvo/models/user_model.dart';
import 'package:carvo/features/customer/data/model/product_model.dart';
import 'add_product_state.dart';

const String _defaultProductImage =
    "https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=500";

/// All business logic for AddProductScreen — validation, image upload,
/// saving to Firestore, and selection state. The screen only reads
/// [AddProductState] and calls these methods.
class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit({required this.user}) : super(AddProductState.initial());

  final UserModel user;
  final ImagePicker _imagePicker = ImagePicker();

  void selectCategory(String value) =>
      emit(state.copyWith(selectedCategory: value));

  void selectBrand(String value) =>
      emit(state.copyWith(selectedBrand: value));

  void selectCondition(ProductCondition value) =>
      emit(state.copyWith(condition: value));

  /// Opens the camera/gallery, then uploads the picked image straight to
  /// Cloudinary. Only the resulting URL is ever saved to Firestore — the
  /// raw bytes are kept in memory just long enough to show a preview.
  Future<void> pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (file == null) return; // user cancelled the picker

      final Uint8List bytes = await file.readAsBytes();
      emit(state.copyWith(
        pickedImageBytes: bytes,
        imageStatus: ImageUploadStatus.uploading,
        imageMessage: '',
      ));

      final String url = await CloudinaryService.uploadImageFile(file.path);

      emit(state.copyWith(
        uploadedImageUrl: url,
        imageStatus: ImageUploadStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        imageStatus: ImageUploadStatus.failure,
        imageMessage: "تعذر رفع الصورة، حاول مرة أخرى",
      ));
    }
  }

  void removeImage() {
    emit(state.copyWith(
      clearPickedImageBytes: true,
      clearUploadedImageUrl: true,
      imageStatus: ImageUploadStatus.idle,
      imageMessage: '',
    ));
  }

  /// Validates the given raw form values, waits for any in-flight image
  /// upload, and saves the product to Firestore.
  Future<void> saveProduct({
    required String name,
    required String priceText,
    required String partNumber,
    required String brandMarka,
    required String modelName,
  }) async {
    final trimmedName = name.trim();
    final trimmedPrice = priceText.trim();

    if (trimmedName.isEmpty || trimmedPrice.isEmpty) {
      emit(state.copyWith(
        status: AddProductStatus.failure,
        message: "يرجى إدخال اسم القطعة والسعر",
      ));
      return;
    }

    if (state.imageStatus == ImageUploadStatus.uploading) {
      emit(state.copyWith(
        status: AddProductStatus.failure,
        message: "يرجى الانتظار حتى تنتهي عملية رفع الصورة",
      ));
      return;
    }

    final double price = double.tryParse(trimmedPrice) ?? 0.0;
    final bool brandChosen = state.selectedBrand != kProductBrands.first;
    final part = partNumber.trim();

    // ProductModel has no dedicated "part number" field, so that one stays
    // folded into the description. brandMarka/modelName have real fields,
    // so they're set directly below.
    final String description = part.isEmpty ? '' : "رقم القطعة: $part";

    emit(state.copyWith(status: AddProductStatus.submitting));

    try {
      final String id = "prod_${DateTime.now().millisecondsSinceEpoch}";
      final product = ProductModel(
        id: id,
        vendorId: user.uid,
        vendorName: user.shopName ?? user.name,
        name: trimmedName,
        brandName: brandChosen ? state.selectedBrand : "CarVo",
        description: description,
        originalPrice: price * 1.15,
        finalPrice: price,
        category: state.selectedCategory,
        image: state.uploadedImageUrl ?? _defaultProductImage,
        brandMarka: brandMarka.trim(),
        modelName: modelName.trim(),
      );

      await FirestoreService.addProduct(product);

      // Reset everything back to defaults, but keep the success
      // status/message so the UI can react to it.
      emit(AddProductState.initial().copyWith(
        status: AddProductStatus.success,
        message: "تم نشر قطعة الغيار في متجر CarVo بنجاح! 🎉",
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddProductStatus.failure,
        message: "حدث خطأ أثناء الحفظ، حاول مرة أخرى",
      ));
    }
  }
}