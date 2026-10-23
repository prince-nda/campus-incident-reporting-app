import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;

  /// 'student' (default), 'staff' or 'admin'. Only changeable from the
  /// Firebase Console; Firestore rules block clients from editing it.
  final String role;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  bool get isStaff => role == 'staff' || role == 'admin';

  String get firstName {
    final n = name.trim();
    return n.isEmpty ? 'there' : n.split(' ').first;
  }

  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      name: m['name'] as String? ?? '',
      email: m['email'] as String? ?? '',
      role: m['role'] as String? ?? 'student',
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}