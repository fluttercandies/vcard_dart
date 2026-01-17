import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Neo-Brutalism styled chip/tag.
class NeoChip extends StatelessWidget {
  const NeoChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.color,
    this.selectedColor,
    this.avatar,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;
  final Color? color;
  final Color? selectedColor;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final bgColor = selected
        ? (selectedColor ?? AppColors.primary)
        : (color ?? AppColors.surface);
    final textColor = selected ? AppColors.dark : AppColors.textPrimary;

    return GestureDetector(
      onTap: onSelected != null ? () => onSelected!(!selected) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: const [
            BoxShadow(color: AppColors.border, offset: Offset(2, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatar != null) ...[
              avatar!,
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: textColor),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(Icons.close, size: 14, color: textColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Neo-Brutalism styled choice chips group.
class NeoChoiceChips<T> extends StatelessWidget {
  const NeoChoiceChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.labelBuilder,
    this.wrap = true,
    this.spacing = AppSpacing.sm,
    this.runSpacing = AppSpacing.sm,
  });

  final List<T> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final String Function(T)? labelBuilder;
  final bool wrap;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final chips = options.map((option) {
      final label = labelBuilder?.call(option) ?? option.toString();
      return NeoChip(
        label: label,
        selected: selected == option,
        onSelected: (_) => onSelected(option),
      );
    }).toList();

    if (wrap) {
      return Wrap(spacing: spacing, runSpacing: runSpacing, children: chips);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            chips.expand((chip) => [chip, SizedBox(width: spacing)]).toList()
              ..removeLast(),
      ),
    );
  }
}
