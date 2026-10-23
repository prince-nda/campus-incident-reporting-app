import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/incident.dart';
import '../models/incident_enums.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/ui.dart';
import 'app_button.dart';

/// Staff-only control. It is only built for staff users, and Firestore rules
/// reject status writes from anyone else.
class StatusUpdatePanel extends StatefulWidget {
  const StatusUpdatePanel({super.key, required this.incident});
  final Incident incident;

  @override
  State<StatusUpdatePanel> createState() => _StatusUpdatePanelState();
}

class _StatusUpdatePanelState extends State<StatusUpdatePanel> {
  late IncidentStatus _status = widget.incident.status;
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final staffName = context.read<AuthProvider>().profile?.name ?? 'Staff';
    final err = await context.read<IncidentProvider>().updateStatus(
          widget.incident, _status,
          staffName: staffName, note: _note.text);
    if (!mounted) return;
    setState(() => _saving = false);
    if (err == null) {
      _note.clear();
      showSnack(context, 'Status updated to ${_status.label}');
    } else {
      showSnack(context, err, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unchanged = _status == widget.incident.status && _note.text.trim().isEmpty;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.deepPine, width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.admin_panel_settings_outlined,
                size: 18, color: AppColors.deepPine),
            const SizedBox(width: 6),
            Text('Staff actions', style: Theme.of(context).textTheme.titleSmall),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<IncidentStatus>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: [
              for (final s in IncidentStatus.values)
                DropdownMenuItem(
                  value: s,
                  child: Row(children: [
                    Icon(s.icon, size: 18, color: s.color),
                    const SizedBox(width: 8),
                    Text(s.label),
                  ]),
                ),
            ],
            onChanged: (v) => setState(() => _status = v ?? _status),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLines: 2,
            maxLength: 300,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Note to student (optional)',
              hintText: 'e.g. Plumber booked for tomorrow morning',
            ),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Update status',
            icon: Icons.check,
            loading: _saving,
            onPressed: unchanged ? null : _save,
          ),
        ]),
      ),
    );
  }
}