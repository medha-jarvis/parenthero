import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../providers/campaign_provider.dart';

/// Day view showing today's activities.
class DayViewScreen extends ConsumerWidget {
  final String campaignId;
  final int day;

  const DayViewScreen({
    super.key,
    required this.campaignId,
    required this.day,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignAsync = ref.watch(campaignByIdProvider(campaignId));

    return campaignAsync.when(
      data: (campaign) {
        if (campaign == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Day $day')),
            body: const Center(child: Text('Campaign not found')),
          );
        }

        final dayData = campaign.days['$day'];

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header
                GradientBackground(
                  height: 140,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                      Text(
                        'Day $day',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                // Activities
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildActivityCard(
                        context,
                        icon: Icons.play_circle_fill_rounded,
                        title: AppStrings.teachingScript,
                        subtitle: 'Watch the animated lesson',
                        color: AppColors.primary,
                        isCompleted: dayData?.scriptWatched ?? false,
                        onTap: dayData?.scriptWatched ?? false
                            ? null
                            : () => context.push(
                                  '/teaching/${campaign.topicId}/$day',
                                ),
                      ),
                      _buildActivityCard(
                        context,
                        icon: Icons.edit_note_rounded,
                        title: AppStrings.practice,
                        subtitle: 'Solve practice problems',
                        color: AppColors.secondary,
                        isCompleted: dayData?.practiceCompleted ?? false,
                        onTap: dayData?.practiceCompleted ?? false
                            ? null
                            : () => context.push(
                                  '/practice/${campaign.topicId}/$day',
                                ),
                      ),
                      _buildActivityCard(
                        context,
                        icon: Icons.quiz_rounded,
                        title: AppStrings.quiz,
                        subtitle: 'Test your knowledge',
                        color: AppColors.accent,
                        isCompleted: dayData?.quizCompleted ?? false,
                        onTap: dayData?.quizCompleted ?? false
                            ? null
                            : () => context.push(
                                  '/quiz/${campaign.topicId}/$day',
                                ),
                      ),
                      _buildActivityCard(
                        context,
                        icon: Icons.sports_esports_rounded,
                        title: AppStrings.beatTheParent,
                        subtitle: 'Fun challenge game',
                        color: AppColors.subjectColor('science'),
                        isCompleted: dayData?.beatParentCompleted ?? false,
                        onTap: dayData?.beatParentCompleted ?? false
                            ? null
                            : () => context.push(
                                  '/beat-parent/${campaign.topicId}/$day',
                                ),
                      ),
                      _buildActivityCard(
                        context,
                        icon: Icons.auto_awesome_rounded,
                        title: AppStrings.dailySpark,
                        subtitle: 'A fun surprise',
                        color: AppColors.warning,
                        isCompleted: dayData?.sparkRead ?? false,
                        onTap: dayData?.sparkRead ?? false
                            ? null
                            : () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isCompleted,
    required VoidCallback? onTap,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withValues(alpha: 0.15)
                  : color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : icon,
              color: isCompleted ? AppColors.success : color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: AppColors.success)
          else
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
