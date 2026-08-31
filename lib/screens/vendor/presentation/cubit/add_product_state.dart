import 'dart:typed_data';
import 'package:carvo/screens/vendor/presentation/widget/condational_selector.dart';

/// Static option lists — these don't change, so they live outside state.
const List<String> kProductCategories = [
  ' اختر التصنيف',
  'قطع غيار محرك',
  'فرامل وتيل',
  'فلاتر وزيوت',
  'بطاريات وكهرباء',
  'عفشة ومساعدين',
  'إطارات وجنوط',
  'إكسسوارات وعناية',
];

const List<String> kProductBrands = [
  'اختر البراند',
  'BOSCH',
  'DENSO',
  'NGK',
  'MANN',
  'KYB',
  'ACDelco',
  'Valeo',
  'Mahle',
  'Hella',
];

enum AddProductStatus { initial, submitting, success, failure }

/// Status of the separate image pick → Cloudinary upload flow. Kept apart
/// from [AddProductStatus] so an image upload failure doesn't get mixed up
/// with a form-submit failure.
enum ImageUploadStatus { idle, uploading, success, failure }

class AddProductState {
  final String selectedCategory;
  final String selectedBrand;
  final ProductCondition condition;
  final AddProductStatus status;
  final String message;

  /// Bytes of the picked image, kept only for local preview.
  final Uint8List? pickedImageBytes;

  /// Cloudinary secure_url once the upload finishes — this is what
  /// actually gets saved to Firestore.
  final String? uploadedImageUrl;
  final ImageUploadStatus imageStatus;
  final String imageMessage;

  const AddProductState({
    required this.selectedCategory,
    required this.selectedBrand,
    required this.condition,
    required this.status,
    required this.message,
    required this.pickedImageBytes,
    required this.uploadedImageUrl,
    required this.imageStatus,
    required this.imageMessage,
  });

  factory AddProductState.initial() => AddProductState(
        selectedCategory: kProductCategories.first,
        selectedBrand: kProductBrands.first,
        condition: ProductCondition.newItem,
        status: AddProductStatus.initial,
        message: '',
        pickedImageBytes: null,
        uploadedImageUrl: null,
        imageStatus: ImageUploadStatus.idle,
        imageMessage: '',
      );

  AddProductState copyWith({
    String? selectedCategory,
    String? selectedBrand,
    ProductCondition? condition,
    AddProductStatus? status,
    String? message,
    Uint8List? pickedImageBytes,
    bool clearPickedImageBytes = false,
    String? uploadedImageUrl,
    bool clearUploadedImageUrl = false,
    ImageUploadStatus? imageStatus,
    String? imageMessage,
  }) {
    return AddProductState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      message: message ?? this.message,
      pickedImageBytes: clearPickedImageBytes
          ? null
          : (pickedImageBytes ?? this.pickedImageBytes),
      uploadedImageUrl: clearUploadedImageUrl
          ? null
          : (uploadedImageUrl ?? this.uploadedImageUrl),
      imageStatus: imageStatus ?? this.imageStatus,
      imageMessage: imageMessage ?? this.imageMessage,
    );
  }
}