import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident.dart';
import '../models/incident_enums.dart';

/// All Firestore access for the `incidents` collection (CRUD).
class IncidentService {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('incidents');

  String newId() => _col.doc().id;

  /// READ: live stream of the newest reports.
  Stream<List<Incident>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .limit(300)
      .snapshots()
      .map((s) => s.docs.map(Incident.fromDoc).toList());

  /// CREATE
  Future<void> create(String id, Map<String, dynamic> data) =>
      _col.doc(id).set(data);

  /// UPDATE (owner edits while still "submitted")
  Future<void> updateDetails(
    String id, {
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    required bool isAnonymous,
  }) =>
      _col.doc(id).update({
        'title': title.trim(),
        'description': description.trim(),
        'category': category.name,
        'location': location,
        'isAnonymous': isAnonymous,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  /// UPDATE (staff only, enforced by Firestore rules)
  Future<void> updateStatus(
    String id,
    IncidentStatus status, {
    required String staffName,
    String? note,
  }) {
    final event = StatusEvent(
        status: status, at: DateTime.now(), by: staffName, note: note);
    return _col.doc(id).update({
      'status': status.name,
      'staffNote': (note ?? '').trim(),
      'history': FieldValue.arrayUnion([event.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// UPDATE ("I'm affected too" counter, any verified user)
  Future<void> setAffected(String id, String uid, bool affected) =>
      _col.doc(id).update({
        'affectedBy': affected
            ? FieldValue.arrayUnion([uid])
            : FieldValue.arrayRemove([uid]),
      });

  /// DELETE
  Future<void> delete(String id) => _col.doc(id).delete();
}