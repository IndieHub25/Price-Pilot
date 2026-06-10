import 'package:flutter/material.dart';

/// Application-wide color palette.
///
/// Uses a deep space-inspired dark theme with indigo and violet accents
/// for a premium, modern appearance.
class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42E0);

  // Accent palette
  static const Color accent = Color(0xFF00D9FF);
  static const Color accentLight = Color(0xFF66E8FF);
  static const Color accentDark = Color(0xFF00A3BF);

  // Background palette
  static const Color backgroundDark = Color(0xFF0D0D1A);
  static const Color backgroundCard = Color(0xFF1A1A2E);
  static const Color backgroundElevated = Color(0xFF16213E);
  static const Color backgroundSurface = Color(0xFF222244);

  // Text palette
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textHint = Color(0xFF6B6B8D);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status palette
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFF69F0AE);
  static const Color warning = Color(0xFFFFAB00);
  static const Color warningLight = Color(0xFFFFD740);
  static const Color error = Color(0xFFFF1744);
  static const Color errorLight = Color(0xFFFF616F);
  static const Color info = Color(0xFF2979FF);

  // Service brand colors
  static const Color uber = Color(0xFF000000);
  static const Color ola = Color(0xFF1C8C3C);
  static const Color rapido = Color(0xFFFFCC00);

  // Misc
  static const Color divider = Color(0xFF2A2A4A);
  static const Color shimmerBase = Color(0xFF1A1A2E);
  static const Color shimmerHighlight = Color(0xFF2A2A4A);
  static const Color shadow = Color(0x406C63FF);
  static const Color overlay = Color(0x80000000);
  static const Color transparent = Colors.transparent;

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF7B2FBE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, backgroundElevated],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [backgroundCard, backgroundElevated],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
