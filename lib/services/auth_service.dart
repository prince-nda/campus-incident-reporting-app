import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

/// Thin wrapper over Firebase Auth + the `users` collection.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get userChanges => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    final user = cred.user!;
    await user.updateDisplayName(name.trim());
    await _db.collection('users').doc(user.uid).set({
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await user.sendEmailVerification();
  }

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();

  Future<void> resendVerification() async =>
      _auth.currentUser?.sendEmailVerification();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Reloads the user and refreshes the ID token so Firestore rules see the
  /// new `email_verified` claim straight away.
  Future<bool> refreshVerification() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    await _auth.currentUser?.getIdToken(true);
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Creates the profile document if it is missing (e.g. interrupted signup).
  Future<void> ensureProfile(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set({
      'name': user.displayName ?? '',
      'email': (user.email ?? '').toLowerCase(),
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<AppUser?> watchProfile(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((s) => s.exists ? AppUser.fromDoc(s) : null);
}