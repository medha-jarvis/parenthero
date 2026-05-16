import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/subject_badge.dart';
import '../../../providers/campaign_provider.dart';
import '../../../providers/child_provider.dart';

/// Topic library grid screen for browsing and pinning topics.
class CampaignListScreen extends ConsumerStatefulWidget {
  const CampaignListScreen({super.key});

  @override
  ConsumerState<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends ConsumerState<CampaignListScreen> {
  String _selectedSubject = '';
  final List<String> _subjects = ['Math', 'English', 'Science'];

  @override
  Widget build(BuildContext context) {
    final selectedChild = ref.watch(selectedChildProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.topicLibrary),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: selectedChild == null
          ? const EmptyState(
              icon: Icons.child_care_rounded,
              title: 'Select a child first',
              subtitle: 'Go back to dashboard and tap on a child profile.',
            )
          : Column(
              children: [
                // Subject filter chips
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('All', ''),
                      ..._subjects.map((s) => _buildFilterChip(s, s)),
                    ],
                  ),
                ),
                // Topics grid
                Expanded(
                  child: ref.watch(
                    topicsByGradeProvider(selectedChild.grade),
                  ).when(
                    data: (topics) {
                      final filtered = _selectedSubject.isEmpty
                          ? topics
                          : topics
                              .where((t) =>
                                  t.subject.toLowerCase() ==
                                  _selectedSubject.toLowerCase())
                              .toList();

                      if (filtered.isEmpty) {
                        return const EmptyState(
                          icon: Icons.auto_stories_rounded,
                          title: AppStrings.noTopicsFound,
                          subtitle: AppStrings.noTopicsForFilter,
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final topic = filtered[index];
                          return _buildTopicCard(topic, selectedChild.id);
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(child: Text('$e')),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedSubject == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedSubject = value),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildTopicCard(topic, String childId) {
    final color = AppColors.subjectColor(topic.subject);
    final lightColor = AppColors.subjectColorLight(topic.subject);

    return GestureDetector(
      onTap: () {
        _pinTopic(topic.id, childId, topic.title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SubjectBadge(subject: topic.subject, size: SubjectBadgeSize.small),
                    const SizedBox(height: 8),
                    Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.auto_stories_rounded,
                            size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '${topic.estimatedDays} days',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: lightColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pinTopic(
      String topicId, String childId, String topicTitle) async {
    try {
      final campaign =
          await ref.read(campaignProvider.notifier).pinTopic(
                childId: childId,
                topicId: topicId,
              );
      if (!mounted) return;
      context.push('/campaign/${campaign.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pin topic: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
