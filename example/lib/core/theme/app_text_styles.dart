import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles for the Neo-Brutalism design system.
abstract final class AppTextStyles {
  /// Display large - for hero text
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: 4,
    height: 1.2,
  );

  /// Display medium - for page titles
  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: 2,
    height: 1.2,
  );

  /// Display small - for section titles
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1.5,
    height: 1.3,
  );

  /// Headline large
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: 1,
  );

  /// Headline medium
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  /// Title large - for card titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  /// Title medium
  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1,
  );

  /// Label large - for button text
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  /// Label medium - for form labels
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: 1.5,
  );

  /// Label small
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 1,
  );

  /// Body large - for main content
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Body medium - for descriptions
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Body small - for captions
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Monospace - for code/vCard output
  static const TextStyle monospace = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}
