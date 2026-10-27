import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/incident.dart';
import '../../models/incident_enums.dart';
import '../../providers/incident_provider.dart';
import '../../utils/ui.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';

/// Browse, search and filter all reports (or only your own).
class IncidentListScreen extends StatefulWidget {
  const IncidentListScreen({super.key});
  @override
  State<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    final list = p.filtered;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Column(children: [
          TextField(
            controller: _search,
            onChanged: p.setQuery,
            decoration: InputDecoration(
              hintText: 'Search title, place or category',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: p.query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _search.clear();
                        p.setQuery('');
                      }),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: false, label: Text('All reports')),
                ButtonSegment(value: true, label: Text('My reports')),
              ],
              selected: {p.onlyMine},
              onSelectionChanged: (s) => p.setOnlyMine(s.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.pine.withValues(alpha: 0.12),
                selectedForegroundColor: AppColors.deepPine,
              ),
            ),
          ),
        ]),
      ),
      _ChipRow(children: [
        for (final c in IncidentCategory.values)
          FilterChip(
            avatar: Icon(c.icon, size: 16),
            label: Text(c.label),
            selected: p.categoryFilter == c,
            showCheckmark: false,
            onSelected: (_) => p.toggleCategory(c),
          ),
      ]),
      _ChipRow(children: [
        for (final s in IncidentStatus.values)
          FilterChip(
            label: Text(s.label),
            selected: p.statusFilter == s,
            showCheckmark: false,
            avatar: CircleAvatar(radius: 5, backgroundColor: s.color),
            onSelected: (_) => p.toggleStatus(s),
          ),
      ]),
      Expanded(child: _body(context, p, list)),
    ]);
  }

  Widget _body(BuildContext context, IncidentProvider p, List<Incident> list) {
    if (p.loading) return const Center(child: CircularProgressIndicator());
    if (p.error != null) {
      return EmptyState(
          icon: Icons.cloud_off_outlined, title: 'Something went wrong', message: p.error!);
    }
    if (list.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: p.hasActiveFilters ? 'No matching reports' : 'No reports yet',
        message: p.hasActiveFilters
            ? 'Try a different search or clear the filters.'
            : 'Reports submitted on campus will show up here.',
        actionLabel: p.hasActiveFilters ? 'Clear filters' : null,
        onAction: () {
          _search.clear();
          p.clearFilters();
        },
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => IncidentCard(
        incident: list[i],
        onTap: () => openDetail(context, list[i].id),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }
}