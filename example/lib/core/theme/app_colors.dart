import 'package:flutter/material.dart';

/// Neo-Brutalism color palette for the application.
abstract final class AppColors {
  /// Primary color - Bright Yellow
  static const Color primary = Color(0xFFFFDE59);

  /// Secondary color - Hot Pink
  static const Color secondary = Color(0xFFFF6B6B);

  /// Accent color - Teal
  static const Color accent = Color(0xFF4ECDC4);

  /// Dark color - Near Black
  static const Color dark = Color(0xFF1A1A1A);

  /// Light color - Off White
  static const Color light = Color(0xFFF7F7F7);

  /// Border color - Pure Black
  static const Color border = Color(0xFF000000);

  /// Success color - Lawn Green
  static const Color success = Color(0xFF7CFC00);

  /// Error color - Red
  static const Color error = Color(0xFFFF4444);

  /// Warning color - Orange
  static const Color warning = Color(0xFFFF9F43);

  /// Info color - Blue
  static const Color info = Color(0xFF54A0FF);

  /// White
  static const Color white = Color(0xFFFFFFFF);

  /// Background color
  static const Color background = light;

  /// Surface color
  static const Color surface = white;

  /// Text colors
  static const Color textPrimary = dark;
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
}
