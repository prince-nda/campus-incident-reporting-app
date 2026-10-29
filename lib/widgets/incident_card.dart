import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/incident.dart';
import '../utils/formatters.dart';
import 'incident_photo.dart';
import 'status_chip.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident, required this.onTap});
  final Incident incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final small = const TextStyle(color: AppColors.slate, fontSize: 12.5);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            _Thumb(incident),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(incident.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  if (incident.isUrgent)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.flag, size: 16, color: AppColors.urgent),
                    ),
                ]),
                const SizedBox(height: 2),
                Text('${incident.category.label} · ${incident.location}',
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: small),
                const SizedBox(height: 8),
                Row(children: [
                  StatusChip(incident.status),
                  const Spacer(),
                  Text(timeAgo(incident.createdAt), style: small),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb(this.incident);
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 64,
      height: 64,
      color: AppColors.paper,
      child: Icon(incident.category.icon, color: AppColors.slate),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: incident.hasPhoto
          ? IncidentPhoto(incident, width: 64, height: 64, fallback: fallback)
          : fallback,
    );
  }
}