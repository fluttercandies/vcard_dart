import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Neo-Brutalism styled avatar.
class NeoAvatar extends StatelessWidget {
  const NeoAvatar({
    super.key,
    this.text,
    this.imageUrl,
    this.size = 48,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  final String? text;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        border: Border.all(
          color: AppColors.border,
          width: AppSpacing.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(color: AppColors.border, offset: Offset(3, 3)),
        ],
      ),
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildTextAvatar(),
            )
          : _buildTextAvatar(),
    );
  }

  Widget _buildTextAvatar() {
    final displayText = text ?? '?';
    final initials = displayText.length >= 2
        ? displayText.substring(0, 2).toUpperCase()
        : displayText.toUpperCase();

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: textColor ?? AppColors.dark,
          fontWeight: FontWeight.w900,
          fontSize: fontSize ?? size * 0.4,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
