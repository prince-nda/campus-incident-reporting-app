import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/ui.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_photo.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';
import '../../widgets/status_update_panel.dart';

/// Reads the incident from IncidentProvider by id, so status changes made by
/// staff appear here live without any manual refresh.
class IncidentDetailScreen extends StatelessWidget {
  const IncidentDetailScreen({super.key, required this.incidentId});
  final String incidentId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<IncidentProvider>();
    final inc = provider.byId(incidentId);

    if (inc == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.find_in_page_outlined,
          title: 'Report not found',
          message: 'It may have been deleted.',
        ),
      );
    }

    final uid = auth.user!.uid;
    final isOwner = inc.reporterId == uid;
    final isStaff = auth.isStaff;
    final canEdit = isOwner && inc.status.name == 'submitted';
    final canDelete = canEdit || isStaff;
    final showReporter = isOwner || isStaff || !inc.isAnonymous;
    final affected = inc.affectedBy.contains(uid);
    final meta = const TextStyle(color: AppColors.slate, fontSize: 13);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report details'),
        actions: [
          if (canEdit)
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => openReport(context, editing: inc),
            ),
          if (canDelete)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await confirm(context,
                    title: 'Delete this report?',
                    message: 'This cannot be undone.',
                    action: 'Delete',
                    destructive: true);
                if (!ok || !context.mounted) return;
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final err = await context.read<IncidentProvider>().delete(inc);
                if (err == null) nav.pop();
                messenger.showSnackBar(
                    SnackBar(content: Text(err ?? 'Report deleted')));
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (inc.hasPhoto) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: IncidentPhoto(inc, height: 210, width: double.infinity),
            ),
            const SizedBox(height: 16),
          ],
          Row(children: [
            StatusChip(inc.status),
            if (inc.isUrgent) ...[
              const SizedBox(width: 8),
              const Icon(Icons.flag, size: 16, color: AppColors.urgent),
              const SizedBox(width: 2),
              const Text('Urgent',
                  style: TextStyle(
                      color: AppColors.urgent, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ]),
          const SizedBox(height: 10),
          Text(inc.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _MetaRow(Icons.place_outlined, inc.location, meta),
          _MetaRow(inc.category.icon, inc.category.label, meta),
          _MetaRow(Icons.schedule, 'Submitted ${fullDate(inc.createdAt)}', meta),
          _MetaRow(
            Icons.person_outline,
            !showReporter
                ? 'Reported anonymously'
                : (isOwner && inc.isAnonymous)
                ? 'Reported by you (name hidden from other students)'
                : 'Reported by ${inc.reporterName}',
            meta,
          ),
          const SizedBox(height: 18),
          Text('Description', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(inc.description, style: const TextStyle(height: 1.45)),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                const Icon(Icons.groups_outlined, color: AppColors.slate),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    inc.affectedBy.isEmpty
                        ? 'Nobody else has said they are affected yet.'
                        : '${inc.affectedBy.length} '
                        '${inc.affectedBy.length == 1 ? 'student is' : 'students are'} affected',
                  ),
                ),
                if (!isOwner)
                  OutlinedButton(
                    onPressed: () async {
                      final err = await context
                          .read<IncidentProvider>()
                          .toggleAffected(inc, uid);
                      if (err != null && context.mounted) {
                        showSnack(context, err, error: true);
                      }
                    },
                    child: Text(affected ? 'Undo' : "Me too"),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          if (isStaff) ...[
            StatusUpdatePanel(key: ValueKey(inc.status), incident: inc),
            const SizedBox(height: 18),
          ],
          Text('Status timeline', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          StatusTimeline(inc.history),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.icon, this.text, this.style);
  final IconData icon;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: AppColors.slate),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: style)),
    ]),
  );
}