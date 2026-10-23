import 'package:flutter/material.dart';

/// Brand + status palette. Color is reserved for meaning: brand (pine) for
/// actions, and one color per status. Red is only for safety / destructive use.
class AppColors {
  static const pine = Color(0xFF14675B);
  static const deepPine = Color(0xFF0D4A41);
  static const paper = Color(0xFFF6F4F0);
  static const ink = Color(0xFF1E2321);
  static const slate = Color(0xFF5E6663);
  static const stone = Color(0xFFE2DED7);

  static const submitted = Color(0xFF6B7280);
  static const underReview = Color(0xFF8B6B4E);
  static const inProgress = Color(0xFFE8710A);
  static const resolved = Color(0xFF2E8B4E);
  static const rejected = Color(0xFF9CA3AF);
  static const urgent = Color(0xFFC62828);
}