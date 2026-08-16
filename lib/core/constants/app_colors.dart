import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primary Blue Palette ─────────────────────────────
  static const Color primary = Color(0xFF1E6FDF); // main blue
  static const Color primaryLight = Color(0xFF5B9BF5); // lighter blue
  static const Color primaryDark = Color(0xFF1450A3); // darker blue

  // ─── Light Theme ──────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE0E6EF);
  static const Color lightTextPrimary = Color(0xFF1A1D23);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextHint = Color(0xFF9CA3AF);

  // ─── Dark Theme ───────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D23);
  static const Color darkCardBg = Color(0xFF23272F);
  static const Color darkBorder = Color(0xFF2E3340);
  static const Color darkTextPrimary = Color(0xFFF1F3F7);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextHint = Color(0xFF6B7280);

  // ─── Semantic Colors (same for both themes) ───────────
  static const Color success = Color(0xFF22C55E); // green
  static const Color warning = Color(0xFFF59E0B); // amber
  static const Color error = Color(0xFFEF4444); // red
  static const Color info = Color(0xFF3B82F6); // blue

  // ─── Risk Level Colors ────────────────────────────────
  static const Color riskLow = Color(0xFF22C55E); // green
  static const Color riskMedium = Color(0xFFF59E0B); // amber
  static const Color riskHigh = Color(0xFFEF4444); // red

  // ─── Attendance Colors ────────────────────────────────
  static const Color attendanceGood = Color(0xFF22C55E); // >= 75%
  static const Color attendanceWarning = Color(0xFFF59E0B); // 60-75%
  static const Color attendanceDanger = Color(0xFFEF4444); // < 60%
}
