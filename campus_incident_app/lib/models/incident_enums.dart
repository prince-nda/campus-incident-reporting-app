import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum IncidentStatus {
  submitted,
  underReview,
  inProgress,
  resolved,
  rejected;

  static IncidentStatus fromName(String? name) => IncidentStatus.values
      .firstWhere((s) => s.name == name, orElse: () => IncidentStatus.submitted);

  String get label => switch (this) {
        IncidentStatus.submitted => 'Submitted',
        IncidentStatus.underReview => 'Under review',
        IncidentStatus.inProgress => 'In progress',
        IncidentStatus.resolved => 'Resolved',
        IncidentStatus.rejected => 'Rejected',
      };

  Color get color => switch (this) {
        IncidentStatus.submitted => AppColors.submitted,
        IncidentStatus.underReview => AppColors.underReview,
        IncidentStatus.inProgress => AppColors.inProgress,
        IncidentStatus.resolved => AppColors.resolved,
        IncidentStatus.rejected => AppColors.rejected,
      };

  IconData get icon => switch (this) {
        IncidentStatus.submitted => Icons.schedule,
        IncidentStatus.underReview => Icons.visibility_outlined,
        IncidentStatus.inProgress => Icons.build_outlined,
        IncidentStatus.resolved => Icons.check_circle_outline,
        IncidentStatus.rejected => Icons.block,
      };

  /// Open = still needs staff attention or work.
  bool get isOpen =>
      this == IncidentStatus.submitted ||
      this == IncidentStatus.underReview ||
      this == IncidentStatus.inProgress;
}

/// Categories use outlined icons only; color is reserved for status.
enum IncidentCategory {
  facilities,
  water,
  electricity,
  furniture,
  sanitation,
  safety;

  static IncidentCategory fromName(String? name) => IncidentCategory.values
      .firstWhere((c) => c.name == name, orElse: () => IncidentCategory.facilities);

  String get label => switch (this) {
        IncidentCategory.facilities => 'Facilities',
        IncidentCategory.water => 'Water',
        IncidentCategory.electricity => 'Electricity',
        IncidentCategory.furniture => 'Furniture',
        IncidentCategory.sanitation => 'Sanitation',
        IncidentCategory.safety => 'Safety',
      };

  IconData get icon => switch (this) {
        IncidentCategory.facilities => Icons.apartment_outlined,
        IncidentCategory.water => Icons.water_drop_outlined,
        IncidentCategory.electricity => Icons.bolt_outlined,
        IncidentCategory.furniture => Icons.chair_alt_outlined,
        IncidentCategory.sanitation => Icons.cleaning_services_outlined,
        IncidentCategory.safety => Icons.shield_outlined,
      };
}