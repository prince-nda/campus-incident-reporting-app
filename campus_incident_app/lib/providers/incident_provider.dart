import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/incident.dart';
import '../models/incident_enums.dart';
import '../services/incident_service.dart';
import '../services/storage_service.dart';
import 'auth_provider.dart';

/// Single source of truth for incidents. Listens to Firestore once and every
/// screen (home, list, detail, staff dashboard) reads from here, so a status
/// change shows up everywhere immediately.
class IncidentProvider extends ChangeNotifier {
  IncidentProvider(this._service, this._storage);

  final IncidentService _service;
  final StorageService _storage;

  StreamSubscription<List<Incident>>? _sub;
  String? _uid;
  List<Incident> _all = [];

  bool loading = false;
  bool submitting = false;
  String? error;

  // Browse filters (shared by the Reports tab).
  String query = '';
  IncidentCategory? categoryFilter;
  IncidentStatus? statusFilter;
  bool onlyMine = false;

  List<Incident> get all => _all;

  /// Called by ChangeNotifierProxyProvider whenever auth changes.
  void attach(AuthProvider auth) {
    final uid = auth.ready ? auth.user!.uid : null;
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    _all = [];
    error = null;
    if (uid == null) {
      loading = false;
      Future.microtask(notifyListeners);
      return;
    }
    loading = true;
    _sub = _service.watchAll().listen((list) {
      _all = list;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (_) {
      loading = false;
      error = 'Could not load reports. Check your connection.';
      notifyListeners();
    });
  }

  // ---------- queries ----------
  Incident? byId(String id) {
    for (final i in _all) {
      if (i.id == id) return i;
    }
    return null;
  }

  List<Incident> mine() => _all.where((i) => i.reporterId == _uid).toList();

  int count(IncidentStatus s, {bool mineOnly = false}) =>
      (mineOnly ? mine() : _all).where((i) => i.status == s).length;

  int openCount({bool mineOnly = false}) =>
      (mineOnly ? mine() : _all).where((i) => i.status.isOpen).length;

  int get urgentCount => _all.where((i) => i.isUrgent).length;

  List<Incident> get filtered {
    final q = query.trim().toLowerCase();
    return _all.where((i) {
      if (onlyMine && i.reporterId != _uid) return false;
      if (categoryFilter != null && i.category != categoryFilter) return false;
      if (statusFilter != null && i.status != statusFilter) return false;
      if (q.isEmpty) return true;
      return i.title.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.location.toLowerCase().contains(q) ||
          i.category.label.toLowerCase().contains(q);
    }).toList();
  }

  bool get hasActiveFilters =>
      query.isNotEmpty || categoryFilter != null || statusFilter != null;

  // ---------- filter setters ----------
  void setQuery(String v) {
    query = v;
    notifyListeners();
  }

  void toggleCategory(IncidentCategory c) {
    categoryFilter = categoryFilter == c ? null : c;
    notifyListeners();
  }

  void toggleStatus(IncidentStatus s) {
    statusFilter = statusFilter == s ? null : s;
    notifyListeners();
  }

  void setOnlyMine(bool v) {
    onlyMine = v;
    notifyListeners();
  }

  void clearFilters() {
    query = '';
    categoryFilter = null;
    statusFilter = null;
    notifyListeners();
  }

  // ---------- commands (return an error message or null) ----------
  Future<String?> submit({
    required String uid,
    required String name,
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    required bool anonymous,
    File? photo,
  }) async {
    submitting = true;
    notifyListeners();
    try {
      final id = _service.newId();
      UploadedPhoto? up;
      if (photo != null) {
        up = await _storage.uploadIncidentPhoto(photo, uid, id);
      }
      await _service
          .create(
            id,
            Incident.createMap(
              title: title,
              description: description,
              category: category,
              location: location,
              reporterId: uid,
              reporterName: name,
              isAnonymous: anonymous,
              photoUrl: up?.url,
              photoPath: up?.path,
            ),
          )
          .timeout(const Duration(seconds: 20));
      return null;
    } on FirebaseException catch (e) {
      return _firebaseMessage(e);
    } catch (_) {
      return 'Could not submit the report. Check your connection and try again.';
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<String?> edit(
    Incident i, {
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    required bool anonymous,
  }) async {
    submitting = true;
    notifyListeners();
    try {
      await _service.updateDetails(i.id,
          title: title,
          description: description,
          category: category,
          location: location,
          isAnonymous: anonymous);
      return null;
    } on FirebaseException catch (e) {
      return _firebaseMessage(e);
    } catch (_) {
      return 'Could not save changes.';
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<String?> updateStatus(
    Incident i,
    IncidentStatus status, {
    required String staffName,
    String? note,
  }) async {
    try {
      await _service.updateStatus(i.id, status, staffName: staffName, note: note);
      return null;
    } on FirebaseException catch (e) {
      return _firebaseMessage(e);
    } catch (_) {
      return 'Could not update the status.';
    }
  }

  Future<String?> toggleAffected(Incident i, String uid) async {
    try {
      await _service.setAffected(i.id, uid, !i.affectedBy.contains(uid));
      return null;
    } on FirebaseException catch (e) {
      return _firebaseMessage(e);
    }
  }

  Future<String?> delete(Incident i) async {
    try {
      await _service.delete(i.id);
      await _storage.delete(i.photoPath);
      return null;
    } on FirebaseException catch (e) {
      return _firebaseMessage(e);
    } catch (_) {
      return 'Could not delete the report.';
    }
  }

  String _firebaseMessage(FirebaseException e) => switch (e.code) {
        'permission-denied' => 'You do not have permission to do that.',
        'unavailable' || 'network-request-failed' => 'No internet connection.',
        _ => e.message ?? 'Something went wrong.',
      };

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}