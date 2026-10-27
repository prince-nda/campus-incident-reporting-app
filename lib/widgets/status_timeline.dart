import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/incident.dart';
import '../utils/formatters.dart';

/// Vertical history of status changes, newest last.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline(this.events, {super.key});
  final List<StatusEvent> events;

  @override
  Widget build(BuildContext context) {
    final sorted = [...events]..sort((a, b) => a.at.compareTo(b.at));
    return Column(
      children: [
        for (var i = 0; i < sorted.length; i++)
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 28,
                child: Column(children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: sorted[i].status.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(sorted[i].status.icon, size: 13, color: Colors.white),
                  ),
                  if (i < sorted.length - 1)
                    Expanded(child: Container(width: 2, color: AppColors.stone)),
                ]),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(sorted[i].status.label,
                        style: Theme.of(context).textTheme.titleSmall),
                    Text('${fullDate(sorted[i].at)} · ${sorted[i].by}',
                        style: const TextStyle(color: AppColors.slate, fontSize: 12)),
                    if (sorted[i].note != null && sorted[i].note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(sorted[i].note!),
                      ),
                  ]),
                ),
              ),
            ]),
          ),
      ],
    );
  }
}