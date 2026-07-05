import 'package:flutter/material.dart';

/// Centralized color palette for StudentOS.
///
/// All colors used throughout the application are defined here.
/// Never hardcode colors directly in widgets — always reference [AppColors].
class AppColors {
  AppColors._();

  // ─── Brand Colors ─────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryPurple = Color(0xFF7C3AED);

  // ─── Background & Surface ─────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ─── Text ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Status Colors ────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Status Light Backgrounds ─────────────────────────────────────────
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ─── Gradient Presets ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, secondaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Miscellaneous ────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x1A0F172A);
  static const Color shimmer = Color(0xFFE2E8F0);
  static const Color navBarBackground = Color(0xFFFFFFFF);
  static const Color navBarUnselected = Color(0xFF94A3B8);
}
