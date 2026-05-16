import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

/// Reusable app button with gradient support and loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isGradient = false,
    this.isOutlined = false,
    this.isText = false,
    this.icon,
    this.expanded = true,
    this.size = ButtonSize.large,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool isGradient;
  final bool isOutlined;
  final bool isText;
  final Widget? icon;
  final bool expanded;
  final ButtonSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveDisabled = isDisabled || isLoading;

    if (isText) {
      return TextButton.icon(
        onPressed: effectiveDisabled ? null : onPressed,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(label),
      );
    }

    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: effectiveDisabled ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon ?? const SizedBox.shrink()),
        label: Text(label),
      );
    }

    final Widget button = ElevatedButton.icon(
      onPressed: effectiveDisabled ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : (icon ?? const SizedBox.shrink()),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(
          expanded ? double.infinity : 0,
          size == ButtonSize.small ? 40 : size == ButtonSize.medium ? 48 : 56,
        ),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    if (isGradient) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: button,
      );
    }

    return button;
  }
}

enum ButtonSize { small, medium, large }
