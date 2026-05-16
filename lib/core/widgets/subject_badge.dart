import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

/// Subject badge chip with subject-specific color.
class SubjectBadge extends StatelessWidget {
  const SubjectBadge({
    super.key,
    required this.subject,
    this.size = SubjectBadgeSize.medium,
  });

  final String subject;
  final SubjectBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.subjectColor(subject);
    final lightColor = AppColors.subjectColorLight(subject);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size == SubjectBadgeSize.small ? 8 : 12,
        vertical: size == SubjectBadgeSize.small ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: lightColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        subject,
        style: TextStyle(
          color: color,
          fontSize: size == SubjectBadgeSize.small ? 11 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum SubjectBadgeSize { small, medium, large }
