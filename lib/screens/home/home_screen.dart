import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/incident_enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/ui.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/stat_tile.dart';

/// Student home: greeting, call to action, personal summary, recent reports.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAll});
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final incidents = context.watch<IncidentProvider>();
    final mine = incidents.mine();
    final recent = mine.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        Text('Hello, ${auth.profile?.firstName ?? ''}',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        const Text('Help keep our campus safe and working.',
            style: TextStyle(color: AppColors.slate)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AppColors.pine, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('See something broken?',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            const Text('Tell us where and what. Staff are notified right away.',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => openReport(context),
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: AppColors.deepPine),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Report an issue'),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        Text('My reports', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: StatTile(
                  label: 'Total',
                  value: mine.length,
                  color: AppColors.ink)),
          const SizedBox(width: 10),
          Expanded(
              child: StatTile(
                  label: 'Open',
                  value: incidents.openCount(mineOnly: true),
                  color: AppColors.inProgress)),
          const SizedBox(width: 10),
          Expanded(
              child: StatTile(
                  label: 'Resolved',
                  value: incidents.count(IncidentStatus.resolved, mineOnly: true),
                  color: AppColors.resolved)),
        ]),
        const SizedBox(height: 24),
        Row(children: [
          Text('Recent reports', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ]),
        if (incidents.loading)
          const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()))
        else if (recent.isEmpty)
          SizedBox(
            height: 220,
            child: EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No reports yet',
              message: 'Issues you report will appear here with live status updates.',
              actionLabel: 'Report an issue',
              onAction: () => openReport(context),
            ),
          )
        else
          for (final i in recent) ...[
            IncidentCard(incident: i, onTap: () => openDetail(context, i.id)),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}