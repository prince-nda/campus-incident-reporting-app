import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/incident.dart';
import '../../models/incident_enums.dart';
import '../../providers/incident_provider.dart';
import '../../utils/ui.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/stat_tile.dart';

/// Staff-only overview. Reachable only when profile.role is staff/admin.
class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});
  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  IncidentStatus? _filter;

  List<Incident> _queue(List<Incident> all) {
    final list = all.where((i) => _filter == null || i.status == _filter).toList();
    // Urgent first, then open before closed, then oldest first.
    list.sort((a, b) {
      if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
      if (a.status.isOpen != b.status.isOpen) return a.status.isOpen ? -1 : 1;
      return a.createdAt.compareTo(b.createdAt);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    if (p.loading) return const Center(child: CircularProgressIndicator());
    final queue = _queue(p.all);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        if (p.urgentCount > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.urgent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.urgent.withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              const Icon(Icons.flag, color: AppColors.urgent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${p.urgentCount} open safety '
                  '${p.urgentCount == 1 ? 'report needs' : 'reports need'} attention',
                  style: const TextStyle(
                      color: AppColors.urgent, fontWeight: FontWeight.w700),
                ),
              ),
            ]),
          ),
        Text('Overview', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.3,
          children: [
            for (final s in IncidentStatus.values)
              StatTile(
                label: s.label,
                value: p.count(s),
                color: s.color,
                selected: _filter == s,
                onTap: () => setState(() => _filter = _filter == s ? null : s),
              ),
            StatTile(
              label: 'All reports',
              value: p.all.length,
              color: AppColors.ink,
              selected: _filter == null,
              onTap: () => setState(() => _filter = null),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(_filter == null ? 'Queue' : '${_filter!.label} reports',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        const Text('Safety first, then oldest open reports.',
            style: TextStyle(color: AppColors.slate, fontSize: 12.5)),
        const SizedBox(height: 10),
        if (queue.isEmpty)
          const SizedBox(
            height: 200,
            child: EmptyState(
              icon: Icons.task_alt,
              title: 'Nothing here',
              message: 'No reports match this status.',
            ),
          )
        else
          for (final i in queue) ...[
            IncidentCard(incident: i, onTap: () => openDetail(context, i.id)),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}