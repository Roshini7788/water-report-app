import 'package:flutter/material.dart';

/// Centralized application color palette matching civic-tech guidelines.
class AppColors {
  // Brand Blue Palette
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color darkBlue = Color(0xFF0D2B45);
  static const Color lightBlue = Color(0xFFEAF4FF);
  static const Color accentBlue = Color(0xFF1E88E5);
  static const Color background = Color(0xFFF6F9FC);
  static const Color white = Color(0xFFFFFFFF);

  // Status Colors
  static const Color statusPending = Color(0xFFEF6C00);     // Orange
  static const Color statusPendingBg = Color(0xFFFFF3E0);   // Light Orange
  static const Color statusInProgress = Color(0xFF1976D2);  // Blue
  static const Color statusInProgressBg = Color(0xFFE3F2FD);// Light Blue
  static const Color statusResolved = Color(0xFF2E7D32);    // Green
  static const Color statusResolvedBg = Color(0xFFE8F5E9);  // Light Green

  // Neutral / Typography Colors
  static const Color textPrimary = Color(0xFF1A212E);
  static const Color textSecondary = Color(0xFF5F6E82);
  static const Color textMuted = Color(0xFF90A0B3);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF0D2B45).withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0D2B45).withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
}
