import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Neo-Brutalism styled empty state widget.
class NeoEmptyState extends StatelessWidget {
  const NeoEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.actionLabel,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.light,
                  border: Border.all(
                    color: AppColors.border,
                    width: AppSpacing.borderWidth,
                  ),
                  boxShadow: const [
                    BoxShadow(color: AppColors.border, offset: Offset(4, 4)),
                  ],
                ),
                child: Icon(icon, size: 40, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            Text(
              title,
              style: AppTextStyles.headlineLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              GestureDetector(
                onTap: action,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppSpacing.borderWidth,
                    ),
                    boxShadow: const [
                      BoxShadow(color: AppColors.border, offset: Offset(4, 4)),
                    ],
                  ),
                  child: Text(actionLabel!, style: AppTextStyles.labelLarge),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
