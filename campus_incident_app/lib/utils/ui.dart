import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../screens/incidents/incident_detail_screen.dart';
import '../screens/incidents/report_incident_screen.dart';

void showSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? const Color(0xFFC62828) : null,
    ));
}

void openDetail(BuildContext context, String id) => Navigator.of(context)
    .push(MaterialPageRoute(builder: (_) => IncidentDetailScreen(incidentId: id)));

Future<bool?> openReport(BuildContext context, {Incident? editing}) =>
    Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => ReportIncidentScreen(editing: editing)));

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
  bool destructive = false,
}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: destructive
              ? TextButton.styleFrom(foregroundColor: const Color(0xFFC62828))
              : null,
          child: Text(action),
        ),
      ],
    ),
  );
  return res ?? false;
}