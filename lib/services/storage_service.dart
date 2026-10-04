import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick Image from Gallery or Camera
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return file;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Upload image to Firebase Storage with progress callback
  Future<String> uploadImage({
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
    Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress?.call(progress);
        }
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image to storage: $e');
      rethrow;
    }
  }
}
