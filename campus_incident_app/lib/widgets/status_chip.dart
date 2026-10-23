import 'package:flutter/material.dart';
import '../models/incident_enums.dart';

/// Soft tint (12%) of the status color for the fill, full color for text.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(status.icon, size: 13, color: status.color),
        const SizedBox(width: 4),
        Text(status.label,
            style: TextStyle(
                color: status.color, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}