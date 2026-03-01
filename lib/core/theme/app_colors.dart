import 'package:flutter/material.dart';

abstract class AppColors {
  // Background hierarchy (darkest to lightest)
  static const Color background = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceVariant = Color(0xFF222240);
  static const Color surfaceHighlight = Color(0xFF2A2A4A);

  // Primary accent - teal green
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryVariant = Color(0xFF00B894);
  static const Color onPrimary = Color(0xFF0D0D0F);

  // Secondary accent - amber
  static const Color secondary = Color(0xFFFFB74D);
  static const Color onSecondary = Color(0xFF0D0D0F);

  // Text colors
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFF616161);

  // Semantic colors
  static const Color success = Color(0xFF66BB6A);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);

  // Mood colors
  static const Color moodGreat = Color(0xFF66BB6A);
  static const Color moodGood = Color(0xFF81C784);
  static const Color moodNeutral = Color(0xFFFFCA28);
  static const Color moodBad = Color(0xFFFF8A65);
  static const Color moodTerrible = Color(0xFFEF5350);

  // Habit preset colors
  static const List<Color> habitPalette = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFF5722),
    Color(0xFF795548),
    Color(0xFF607D8B),
  ];
}
