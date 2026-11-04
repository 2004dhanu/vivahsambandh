import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accent
  static const Color primary = Color(0xFFE5097F);
  static const Color primaryDark = Color(0xFFB50764);
  static const Color primaryLight = Color(0xFFFFF0F6);
  static const Color accent = Color(0xFFFF4081);
  static const Color secondary = Color(0xFF7A0B3B);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE5097F), Color(0xFFB50764)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF9E0B54), Color(0xFFE5097F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neutral Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textMuted = Color(0xFF9E9E9E);

  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF8F9FA);

  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocused = Color(0xFFE5097F);
  static const Color divider = Color(0xFFEEEEEE);

  // Feedback Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
}
