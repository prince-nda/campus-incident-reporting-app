import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_app/core/validators.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/models/incident_enums.dart';

void main() {
  group('Validators', () {
    test('accepts ALU emails only', () {
      expect(Validators.aluEmail('amina@alustudent.com'), isNull);
      expect(Validators.aluEmail('staff@alueducation.com'), isNull);
      expect(Validators.aluEmail('amina@gmail.com'), isNotNull);
      expect(Validators.aluEmail('not-an-email'), isNotNull);
      expect(Validators.aluEmail(''), isNotNull);
    });

    test('password needs 8+ characters', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('longenough1'), isNull);
    });

    test('minLength trims and checks', () {
      expect(Validators.minLength('  ab  ', 5, 'Title'), isNotNull);
      expect(Validators.minLength('Broken tap', 5, 'Title'), isNull);
    });
  });

  group('Status and category', () {
    test('fromName falls back safely', () {
      expect(IncidentStatus.fromName('inProgress'), IncidentStatus.inProgress);
      expect(IncidentStatus.fromName('???'), IncidentStatus.submitted);
      expect(IncidentCategory.fromName(null), IncidentCategory.facilities);
    });

    test('open vs closed', () {
      expect(IncidentStatus.submitted.isOpen, isTrue);
      expect(IncidentStatus.inProgress.isOpen, isTrue);
      expect(IncidentStatus.resolved.isOpen, isFalse);
      expect(IncidentStatus.rejected.isOpen, isFalse);
    });
  });

  group('Models', () {
    test('StatusEvent round-trips through a map', () {
      final e = StatusEvent(
          status: IncidentStatus.inProgress,
          at: DateTime(2026, 10, 15, 10, 24),
          by: 'Facilities',
          note: 'Plumber booked');
      final back = StatusEvent.fromMap(e.toMap());
      expect(back.status, IncidentStatus.inProgress);
      expect(back.by, 'Facilities');
      expect(back.note, 'Plumber booked');
      expect(back.at, DateTime(2026, 10, 15, 10, 24));
    });

    test('createMap starts as submitted with one history entry', () {
      final m = Incident.createMap(
        title: ' Water shortage ',
        description: 'No water since morning on 2nd floor',
        category: IncidentCategory.water,
        location: 'Student residence — Room 204',
        reporterId: 'u1',
        reporterName: 'Amina',
        isAnonymous: false,
      );
      expect(m['title'], 'Water shortage');
      expect(m['status'], 'submitted');
      expect((m['history'] as List).length, 1);
      expect(m['createdAt'], isA<FieldValue>());
    });

    test('open safety incidents are urgent', () {
      Incident make(IncidentCategory c, IncidentStatus s) => Incident(
            id: '1',
            title: 't',
            description: 'd',
            category: c,
            location: 'l',
            status: s,
            reporterId: 'u',
            reporterName: 'n',
            isAnonymous: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
      expect(make(IncidentCategory.safety, IncidentStatus.submitted).isUrgent, isTrue);
      expect(make(IncidentCategory.safety, IncidentStatus.resolved).isUrgent, isFalse);
      expect(make(IncidentCategory.water, IncidentStatus.submitted).isUrgent, isFalse);
    });
  });
}