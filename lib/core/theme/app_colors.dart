import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surfaces
  static const Color background = Color(0xFF0A0A0A); // Midnight Black
  static const Color surfacePrimary = Color(0xFF1F1F1F); // Primary Cards
  static const Color surfaceSecondary = Color(0xFF161616); // Secondary Cards

  // Brand Core
  static const Color primaryAction = Color(0xFFFF0000); // Tactical Red Accent

  // Typography
  static const Color textPrimary = Color(0xFFFFFFFF); // Main White Text
  static const Color textHighlight = Color(0xFF94A3B8);
  static const Color textSubtle = Color(0xFF64748B); // Subtle/Secondary Text

  // Icons
  static const Color inputFieldText = Color(0xFF475569); // Standard Icons

  // Status
  static final Color statusActive = const Color(
    0xFF22C55E,
  ).withValues(alpha: 0.15); // Green opacity 15
  //online
  static const Color online = Color(0xFF22C55E);
  //stroke
  static final Color stroke = const Color(0xFF16A34A).withValues(alpha: 0.8);
}
