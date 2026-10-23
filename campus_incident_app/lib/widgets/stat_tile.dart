import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Flat count tile. A small colored bar on the left carries the meaning.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final int value;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            color: selected ? AppColors.pine : AppColors.stone,
            width: selected ? 1.6 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(children: [
            Container(width: 5, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$value', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 2),
                  Text(label,
                      style: const TextStyle(color: AppColors.slate, fontSize: 12.5)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}