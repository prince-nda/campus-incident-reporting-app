import 'package:cloud_firestore/cloud_firestore.dart';
import 'incident_enums.dart';

/// One entry in an incident's status timeline.
class StatusEvent {
  final IncidentStatus status;
  final DateTime at;
  final String by;
  final String? note;

  const StatusEvent({
    required this.status,
    required this.at,
    required this.by,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'status': status.name,
    'at': Timestamp.fromDate(at),
    'by': by,
    if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
  };

  factory StatusEvent.fromMap(Map<String, dynamic> m) => StatusEvent(
    status: IncidentStatus.fromName(m['status'] as String?),
    at: (m['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    by: m['by'] as String? ?? 'Staff',
    note: m['note'] as String?,
  );
}

class Incident {
  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final IncidentStatus status;
  final String? photoUrl;
  final String? photoPath;
  final String? photoData; // base64 JPEG when stored in Firestore
  final String reporterId;
  final String reporterName;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> affectedBy;
  final List<StatusEvent> history;
  final String? staffNote;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.photoPath,
    this.photoData,
    this.affectedBy = const [],
    this.history = const [],
    this.staffNote,
  });

  /// Safety reports that are still open get flagged as urgent.
  bool get isUrgent => category == IncidentCategory.safety && status.isOpen;

  bool get hasPhoto => photoData != null || photoUrl != null;

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    DateTime ts(String k) => (m[k] as Timestamp?)?.toDate() ?? DateTime.now();
    return Incident(
      id: doc.id,
      title: m['title'] as String? ?? '',
      description: m['description'] as String? ?? '',
      category: IncidentCategory.fromName(m['category'] as String?),
      location: m['location'] as String? ?? '',
      status: IncidentStatus.fromName(m['status'] as String?),
      photoUrl: m['photoUrl'] as String?,
      photoPath: m['photoPath'] as String?,
      photoData: m['photoData'] as String?,
      reporterId: m['reporterId'] as String? ?? '',
      reporterName: m['reporterName'] as String? ?? 'Student',
      isAnonymous: m['isAnonymous'] as bool? ?? false,
      createdAt: ts('createdAt'),
      updatedAt: ts('updatedAt'),
      affectedBy: List<String>.from(m['affectedBy'] as List? ?? const []),
      history: (m['history'] as List? ?? const [])
          .map((e) => StatusEvent.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      staffNote: m['staffNote'] as String?,
    );
  }

  /// Document body for a brand-new report.
  static Map<String, dynamic> createMap({
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    required String reporterId,
    required String reporterName,
    required bool isAnonymous,
    String? photoUrl,
    String? photoPath,
    String? photoData,
  }) =>
      {
        'title': title.trim(),
        'description': description.trim(),
        'category': category.name,
        'location': location,
        'status': IncidentStatus.submitted.name,
        'photoUrl': photoUrl,
        'photoPath': photoPath,
        'photoData': photoData,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'isAnonymous': isAnonymous,
        'affectedBy': <String>[],
        'history': [
          StatusEvent(
            status: IncidentStatus.submitted,
            at: DateTime.now(),
            by: isAnonymous ? 'Reporter' : reporterName,
          ).toMap(),
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}