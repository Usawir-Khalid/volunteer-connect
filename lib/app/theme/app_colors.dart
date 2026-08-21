import 'package:flutter/material.dart';

/// Centralized color palette for Volunteer Connect.
///
/// All application UI colors should come from this class instead of
/// defining raw color values directly inside widgets.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF00796B);
  static const Color primaryDark = Color(0xFF005B52);
  static const Color primaryLight = Color(0xFFE0F2F0);

  // Backgrounds & surfaces
  static const Color background = Color(0xFFF5F7FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color secondarySurface = Color(0xFFF0F4F8);

  // Text
  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF52606D);
  static const Color textMuted = Color(0xFF82909C);

  // Borders
  static const Color border = Color(0xFFD9E2EC);

  // Semantic colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  // Common
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}