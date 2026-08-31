import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryUploadException implements Exception {
  final String message;
  CloudinaryUploadException(this.message);
  @override
  String toString() => message;
}

/// Uploads images to Cloudinary using an unsigned upload preset, so no
/// API secret ever ships inside the app. Built on the `cloudinary_public`
/// package already in this project's pubspec.
///
/// One-time setup in your Cloudinary dashboard:
/// 1. Settings → Upload → Add upload preset.
/// 2. Set "Signing Mode" to "Unsigned".
/// 3. Copy your cloud name and the preset name into the constants below.
class CloudinaryService {
  // TODO: replace with your own values from cloudinary.com/console
  static const String _cloudName = 'dex177xix';
  static const String _uploadPreset = 'carvo_flutter';

  static final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  /// Uploads the image at [filePath] (an XFile.path from image_picker) and
  /// returns its Cloudinary secure_url.
  static Future<String> uploadImageFile(String filePath) async {
    try {
      final CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          filePath,
          resourceType: CloudinaryResourceType.Image,
          folder: 'carvo_products',
        ),
      );
      return response.secureUrl;
    } on CloudinaryException {
      throw CloudinaryUploadException('فشل رفع الصورة، حاول مرة أخرى');
    }
  }
}