import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Neo-Brutalism styled dropdown.
class NeoDropdown<T> extends StatelessWidget {
  const NeoDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.labelMedium),
          const SizedBox(height: AppSpacing.xs),
        ],
        Container(
          decoration: BoxDecoration(
            color: enabled ? AppColors.surface : AppColors.light,
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.border,
              width: AppSpacing.borderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.border,
                offset: Offset(
                  AppSpacing.shadowOffset,
                  AppSpacing.shadowOffset,
                ),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: enabled ? onChanged : null,
              isExpanded: true,
              hint: hint != null
                  ? Text(
                      hint!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                    )
                  : null,
              style: AppTextStyles.bodyMedium,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.dark,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
