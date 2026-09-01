import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../models/user_model.dart';

/// Thrown when the user cancels the file picker dialog.
class FilePickCancelledException implements Exception {}
 
class ExcelUploadService {
  ExcelUploadService._();

   
  static Future<String> pickAndUploadExcel(UserModel user) async {
    final List<PlatformFile> result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'pdf'],
      allowMultiple: false,
    );

    if (result.isEmpty) {
      throw FilePickCancelledException();
    }

    final PlatformFile file = result.first;
    final Uint8List fileBytes = await file.readAsBytes();
    final String fileName = file.name;

    // Cloudinary
    final cloudinary = CloudinaryPublic(
      'dex177xix',
      'carvo_flutter',
      cache: false,
    );

    final CloudinaryResponse response = await cloudinary.uploadFile(
      CloudinaryFile.fromBytesData(
        fileBytes,
        identifier: fileName,
        folder: 'excel_sheets',
      ),
    );

    final String excelUrl = response.secureUrl;

    // Firestore
    await FirebaseFirestore.instance.collection('excel_uploads').add({
      'userId': user.uid,
      'userName': user.name,
      'shopName': user.shopName ?? user.name,
      'fileName': fileName,
      'fileUrl': excelUrl,
      'uploadedAt': FieldValue.serverTimestamp(),
    });

    return excelUrl;
  }
}