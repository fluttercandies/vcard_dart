import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Neo-Brutalism styled card with shadow offset effect.
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.shadowColor,
    this.padding,
    this.margin,
    this.shadowOffset = 4,
    this.onTap,
  });

  final Widget child;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double shadowOffset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.surface;
    final border = borderColor ?? AppColors.border;
    final shadow = shadowColor ?? AppColors.border;

    Widget card = Container(
      margin: margin ?? const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: border, width: AppSpacing.borderWidth),
        boxShadow: [
          BoxShadow(color: shadow, offset: Offset(shadowOffset, shadowOffset)),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        child: child,
      ),
    );

    if (onTap != null) {
      card = _TapEffect(onTap: onTap!, shadowOffset: shadowOffset, child: card);
    }

    return card;
  }
}

/// Widget that handles tap effect animation.
class _TapEffect extends StatefulWidget {
  const _TapEffect({
    required this.child,
    required this.onTap,
    required this.shadowOffset,
  });

  final Widget child;
  final VoidCallback onTap;
  final double shadowOffset;

  @override
  State<_TapEffect> createState() => _TapEffectState();
}

class _TapEffectState extends State<_TapEffect> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _isPressed
            ? Matrix4.translationValues(
                widget.shadowOffset / 2,
                widget.shadowOffset / 2,
                0,
              )
            : Matrix4.identity(),
        child: widget.child,
      ),
    );
  }
}
