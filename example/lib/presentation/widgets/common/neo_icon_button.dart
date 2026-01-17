import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Neo-Brutalism styled icon button.
class NeoIconButton extends StatefulWidget {
  const NeoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.iconColor,
    this.borderColor,
    this.size = 40,
    this.iconSize = 20,
    this.shadowOffset = 3,
    this.tooltip,
    this.isDisabled = false,
  });

  /// Primary icon button variant.
  factory NeoIconButton.primary({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 40,
    double iconSize = 20,
    String? tooltip,
    bool isDisabled = false,
  }) {
    return NeoIconButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      color: AppColors.primary,
      iconColor: AppColors.dark,
      size: size,
      iconSize: iconSize,
      tooltip: tooltip,
      isDisabled: isDisabled,
    );
  }

  /// Danger icon button variant.
  factory NeoIconButton.danger({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 40,
    double iconSize = 20,
    String? tooltip,
    bool isDisabled = false,
  }) {
    return NeoIconButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      color: AppColors.error,
      iconColor: AppColors.light,
      size: size,
      iconSize: iconSize,
      tooltip: tooltip,
      isDisabled: isDisabled,
    );
  }

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? iconColor;
  final Color? borderColor;
  final double size;
  final double iconSize;
  final double shadowOffset;
  final String? tooltip;
  final bool isDisabled;

  @override
  State<NeoIconButton> createState() => _NeoIconButtonState();
}

class _NeoIconButtonState extends State<NeoIconButton> {
  bool _isPressed = false;

  bool get _isEnabled => !widget.isDisabled && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final bgColor = _isEnabled
        ? (widget.color ?? AppColors.surface)
        : AppColors.surface.withValues(alpha: 0.5);
    final iconColor = _isEnabled
        ? (widget.iconColor ?? AppColors.dark)
        : AppColors.textHint;
    final borderColor = widget.borderColor ?? AppColors.border;

    Widget button = GestureDetector(
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        transform: _isPressed
            ? Matrix4.translationValues(
                widget.shadowOffset / 2,
                widget.shadowOffset / 2,
                0,
              )
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: borderColor,
                    offset: Offset(widget.shadowOffset, widget.shadowOffset),
                  ),
                ],
        ),
        child: Center(
          child: Icon(widget.icon, size: widget.iconSize, color: iconColor),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
