import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../../core/widgets/subject_badge.dart';
import '../../../providers/campaign_provider.dart';

/// Campaign detail screen showing the 5-day timeline.
class CampaignDetailScreen extends ConsumerStatefulWidget {
  final String campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  ConsumerState<CampaignDetailScreen> createState() =>
      _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final campaignAsync = ref.watch(campaignByIdProvider(widget.campaignId));

    return campaignAsync.when(
      data: (campaign) {
        if (campaign == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Campaign')),
            body: const EmptyState(
              icon: Icons.auto_stories_rounded,
              title: 'Campaign not found',
            ),
          );
        }

        final currentDay = campaign.currentDay;
        final progress = campaign.progress;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header
                GradientBackground(
                  height: 200,
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
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Day $currentDay of 5',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Learning Campaign',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ProgressRing(
                            progress: progress / 100,
                            size: 64,
                            strokeWidth: 5,
                            color: Colors.white,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            child: Text(
                              '${progress.toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Day list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final dayNum = index + 1;
                      final day = campaign.days['$dayNum'];
                      final isCurrentDay = dayNum == currentDay;
                      final isCompleted = day?.completed ?? false;
                      final isLocked = dayNum > currentDay;

                      return _buildDayCard(
                        dayNum: dayNum,
                        isCurrentDay: isCurrentDay,
                        isCompleted: isCompleted,
                        isLocked: isLocked,
                        day: day,
                        campaignId: widget.campaignId,
                      );
                    },
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

  Widget _buildDayCard({
    required int dayNum,
    required bool isCurrentDay,
    required bool isCompleted,
    required bool isLocked,
    required day,
    required String campaignId,
  }) {
    final statusColor = isCompleted
        ? AppColors.success
        : isCurrentDay
            ? AppColors.primary
            : AppColors.disabled;
    final bgOpacity = isLocked ? 0.5 : 1.0;

    return Opacity(
      opacity: bgOpacity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isCurrentDay
              ? const BorderSide(color: AppColors.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLocked
              ? null
              : () => context.push('/campaign/$campaignId/day/$dayNum'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : isLocked
                                ? Icons.lock_rounded
                                : Icons.play_arrow_rounded,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Day $dayNum',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: isLocked
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (day != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Quiz: ${day.quizScore}/${day.quizMax}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isCurrentDay && !isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (isCompleted)
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 24),
                  ],
                ),
                if (!isLocked && !isCompleted) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: day != null
                        ? [
                            if (day.scriptWatched) 1,
                            if (day.practiceCompleted) 1,
                            if (day.quizCompleted) 1,
                            if (day.beatParentCompleted) 1,
                            if (day.sparkRead) 1,
                          ].fold(0.0, (a, b) => a + b) / 5
                        : 0,
                    backgroundColor: AppColors.surface,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMiniStatus(Icons.play_circle_outline,
                          'Script', day?.scriptWatched ?? false),
                      const SizedBox(width: 8),
                      _buildMiniStatus(Icons.edit_note_rounded,
                          'Practice', day?.practiceCompleted ?? false),
                      const SizedBox(width: 8),
                      _buildMiniStatus(Icons.quiz_outlined,
                          'Quiz', day?.quizCompleted ?? false),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatus(IconData icon, String label, bool done) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: done ? AppColors.success : AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: done ? AppColors.success : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
