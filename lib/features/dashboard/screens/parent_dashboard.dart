import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/child_provider.dart';
import '../../auth/screens/onboarding_screen.dart';
import '../widgets/child_switch_widget.dart';

/// Parent dashboard with child profiles, progress overview, and quick actions.
class ParentDashboard extends ConsumerStatefulWidget {
  const ParentDashboard({super.key});

  @override
  ConsumerState<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends ConsumerState<ParentDashboard> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final childrenAsync = ref.watch(childrenStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            GradientBackground(
              height: 180,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.appName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.appTagline,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search_rounded,
                                color: Colors.white),
                            onPressed: () => context.push('/search'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined,
                                color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined,
                                color: Colors.white),
                            onPressed: () => context.push('/settings'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Child switch
                  childrenAsync.when(
                    data: (children) => ChildSwitchWidget(
                      children: children,
                      childIds: children.map((c) => c.id).toList(),
                    ),
                    loading: () => const SizedBox(
                      height: 56,
                      child: Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: childrenAsync.when(
                data: (children) {
                  if (children.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.child_care_rounded,
                              size: 64, color: AppColors.textTertiary),
                          const SizedBox(height: 16),
                          const Text(AppStrings.noChildrenYet),
                          const SizedBox(height: 8),
                          const Text(AppStrings.addFirstChild),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const OnboardingScreen(),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text(AppStrings.addChild),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: children.length + 1,
                    itemBuilder: (context, index) {
                      if (index == children.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const OnboardingScreen(),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text(AppStrings.addChild),
                          ),
                        );
                      }
                      final child = children[index];
                      return _buildChildCard(context, child);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, ChildProfile child) {
    return AppCard(
      onTap: () {
        ref.read(selectedChildIdProvider.notifier).state = child.id;
        context.push('/campaigns');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(
                name: child.name,
                avatarIndex: child.avatarIndex,
                size: 56,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grade ${child.grade} • ${child.board}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              ProgressRing(
                progress: child.stats.accuracy / 100,
                size: 56,
                strokeWidth: 4,
                color: AppColors.subjectColor('math'),
                child: Text(
                  '${child.stats.accuracy.toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStat(
                Icons.local_fire_department_rounded,
                '${child.stats.streak} ${AppStrings.days}',
                AppStrings.streak,
              ),
              const SizedBox(width: 16),
              _buildStat(
                Icons.auto_stories_rounded,
                '${child.stats.totalTopics}',
                AppStrings.topicsCompleted,
              ),
              const SizedBox(width: 16),
              _buildStat(
                Icons.quiz_rounded,
                '${child.stats.totalQuizzes}',
                AppStrings.quizzesTaken,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(selectedChildIdProvider.notifier).state = child.id;
                    context.push('/campaigns');
                  },
                  child: Text(AppStrings.pinATopic),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(selectedChildIdProvider.notifier).state = child.id;
                    context.push('/analytics');
                  },
                  child: const Text(AppStrings.progress),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
