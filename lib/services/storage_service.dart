import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadedPhoto {
  final String url;
  final String path;
  const UploadedPhoto(this.url, this.path);
}

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UploadedPhoto> uploadIncidentPhoto(
      File file, String uid, String incidentId) async {
    final path = 'incident_photos/$uid/$incidentId.jpg';
    final ref = _storage.ref(path);
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return UploadedPhoto(await ref.getDownloadURL(), path);
  }

  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await _storage.ref(path).delete();
    } catch (_) {
      // Photo may already be gone or belong to another user; ignore.
    }
  }
}