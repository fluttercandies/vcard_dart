import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Neo-Brutalism styled button with shadow offset effect.
class NeoButton extends StatefulWidget {
  const NeoButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.textColor,
    this.borderColor,
    this.shadowColor,
    this.width,
    this.height = 48,
    this.shadowOffset = 4,
    this.isLoading = false,
    this.isDisabled = false,
  });

  /// Primary button variant.
  factory NeoButton.primary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
    double height = 48,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return NeoButton(
      key: key,
      onPressed: onPressed,
      color: AppColors.primary,
      textColor: AppColors.dark,
      width: width,
      height: height,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: child,
    );
  }

  /// Secondary button variant.
  factory NeoButton.secondary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
    double height = 48,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return NeoButton(
      key: key,
      onPressed: onPressed,
      color: AppColors.secondary,
      textColor: AppColors.light,
      width: width,
      height: height,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: child,
    );
  }

  /// Accent button variant.
  factory NeoButton.accent({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
    double height = 48,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return NeoButton(
      key: key,
      onPressed: onPressed,
      color: AppColors.accent,
      textColor: AppColors.dark,
      width: width,
      height: height,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: child,
    );
  }

  /// Outlined button variant.
  factory NeoButton.outlined({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
    double height = 48,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return NeoButton(
      key: key,
      onPressed: onPressed,
      color: AppColors.surface,
      textColor: AppColors.dark,
      width: width,
      height: height,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: child,
    );
  }

  /// Danger button variant.
  factory NeoButton.danger({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
    double height = 48,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return NeoButton(
      key: key,
      onPressed: onPressed,
      color: AppColors.error,
      textColor: AppColors.light,
      width: width,
      height: height,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: child,
    );
  }

  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double? width;
  final double height;
  final double shadowOffset;
  final bool isLoading;
  final bool isDisabled;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  bool get _isEnabled => !widget.isDisabled && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final bgColor = _isEnabled
        ? (widget.color ?? AppColors.primary)
        : AppColors.surface.withValues(alpha: 0.5);
    final textColor = _isEnabled
        ? (widget.textColor ?? AppColors.dark)
        : AppColors.textHint;
    final borderColor = widget.borderColor ?? AppColors.border;
    final shadowColor = widget.shadowColor ?? AppColors.border;

    return GestureDetector(
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
        width: widget.width,
        height: widget.height,
        transform: _isPressed
            ? Matrix4.translationValues(
                widget.shadowOffset / 2,
                widget.shadowOffset / 2,
                0,
              )
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: AppSpacing.borderWidth),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: shadowColor,
                    offset: Offset(widget.shadowOffset, widget.shadowOffset),
                  ),
                ],
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor,
                  ),
                )
              : DefaultTextStyle(
                  style: AppTextStyles.labelLarge.copyWith(color: textColor),
                  child: IconTheme(
                    data: IconThemeData(color: textColor, size: 20),
                    child: widget.child,
                  ),
                ),
        ),
      ),
    );
  }
}
