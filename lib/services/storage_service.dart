import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class UploadedPhoto {
  final String url;
  final String path;
  const UploadedPhoto(this.url, this.path);
}

/// Used only when AppConfig.useFirebaseStorage is true
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UploadedPhoto> uploadIncidentPhoto(
      Uint8List bytes, String uid, String incidentId) async {
    final path = 'incident_photos/$uid/$incidentId.jpg';
    final ref = _storage.ref(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return UploadedPhoto(await ref.getDownloadURL(), path);
  }

  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await _storage.ref(path).delete();
    } catch (_) {

    }
  }
}