import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Holds the auth session: Firebase user + Firestore profile (role).
/// The UI's AuthGate listens to this and routes accordingly.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _userSub = _service.userChanges.listen(_onUser);
  }

  final AuthService _service;
  StreamSubscription<User?>? _userSub;
  StreamSubscription<AppUser?>? _profileSub;

  User? user;
  AppUser? profile;
  bool initializing = true;
  bool busy = false;

  bool get isLoggedIn => user != null;
  bool get isVerified => user?.emailVerified ?? false;
  bool get isStaff => profile?.isStaff ?? false;
  bool get ready => isLoggedIn && isVerified && profile != null;

  Future<void> _onUser(User? u) async {
    user = u;
    await _profileSub?.cancel();
    profile = null;
    if (u == null) {
      initializing = false;
      notifyListeners();
      return;
    }
    try {
      await _service.ensureProfile(u);
    } catch (_) {}
    _profileSub = _service.watchProfile(u.uid).listen((p) {
      profile = p;
      initializing = false;
      notifyListeners();
    }, onError: (_) {
      initializing = false;
      notifyListeners();
    });
    notifyListeners();
  }

  // Each action returns an error message, or null on success.
  Future<String?> signIn(String email, String password) =>
      _run(() => _service.signIn(email, password));

  Future<String?> register(String name, String email, String password) =>
      _run(() => _service.register(name: name, email: email, password: password));

  Future<String?> resetPassword(String email) =>
      _run(() => _service.sendPasswordReset(email));

  Future<String?> resendVerification() => _run(_service.resendVerification);

  Future<bool> checkVerified() async {
    busy = true;
    notifyListeners();
    try {
      final ok = await _service.refreshVerification();
      user = _service.currentUser;
      return ok;
    } catch (_) {
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() => _service.signOut();

  Future<String?> _run(Future<void> Function() action) async {
    busy = true;
    notifyListeners();
    try {
      await action();
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  String _message(FirebaseAuthException e) => switch (e.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'Incorrect email or password.',
        'email-already-in-use' => 'An account with this email already exists.',
        'weak-password' => 'Choose a stronger password (8+ characters).',
        'invalid-email' => 'That email address is not valid.',
        'too-many-requests' => 'Too many attempts. Please wait and try again.',
        'network-request-failed' => 'No internet connection.',
        _ => e.message ?? 'Authentication failed.',
      };

  @override
  void dispose() {
    _userSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}