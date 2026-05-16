import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

/// Circular avatar widget with emoji or initials.
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.name,
    this.avatarIndex = 0,
    this.size = 48,
    this.fontSize,
    this.onTap,
  });

  final String name;
  final int avatarIndex;
  final double size;
  final double? fontSize;
  final VoidCallback? onTap;

  static const List<String> _avatars = [
    '🦁',
    '🐯',
    '🐰',
    '🦊',
    '🐼',
    '🐸',
    '🐵',
    '🦄',
  ];

  String get _emoji => _avatars[avatarIndex % _avatars.length];

  Color get _bgColor => AppColors.avatarColor(avatarIndex);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _bgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _bgColor.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _emoji,
              style: TextStyle(fontSize: fontSize ?? size * 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
