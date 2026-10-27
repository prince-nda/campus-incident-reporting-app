import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/incident_enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/ui.dart';
import '../../widgets/stat_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final incidents = context.watch<IncidentProvider>();
    final profile = auth.profile;
    final mine = incidents.mine();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: auth.isStaff ? AppColors.deepPine : AppColors.pine,
                child: Text(profile?.initial ?? '?',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(profile?.name ?? '', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(profile?.email ?? '',
                      style: const TextStyle(color: AppColors.slate, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (auth.isStaff ? AppColors.deepPine : AppColors.slate)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      auth.isStaff ? 'Campus staff' : 'Student',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: auth.isStaff ? AppColors.deepPine : AppColors.slate,
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Text('Your activity', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: StatTile(label: 'Reports', value: mine.length, color: AppColors.ink)),
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
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lock_outline, size: 18, color: AppColors.slate),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Reports are visible to verified ALU users. Use "Hide my name" when '
                  'reporting to keep your identity from other students.',
                  style: TextStyle(color: AppColors.slate, fontSize: 13, height: 1.4),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
          onPressed: () async {
            final ok = await confirm(context,
                title: 'Log out?', message: 'You will need to log in again.', action: 'Log out');
            if (ok && context.mounted) await context.read<AuthProvider>().signOut();
          },
        ),
      ],
    );
  }
}