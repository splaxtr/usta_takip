import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF101922);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color primary = Color(0xFF1173D4);
  static const Color primaryLight = Color(0xFF4A9DE8);
  static const Color primaryDark = Color(0xFF0D5AA6);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF707070);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Card & Surface
  static const Color cardDark = Color(0xFF252525);
  static const Color divider = Color(0xFF3A3A3A);
  static const Color cardBackground = Color(0xFF1E1E1E);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
