import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_card.dart';

/// Arcade screen with game selection grid.
class ArcadeScreen extends StatelessWidget {
  const ArcadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arcade'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 16),
                child: Text(
                  'Mini Games',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _buildGameCard(
                      context,
                      title: 'Number Rush',
                      subtitle: 'Quick math!',
                      emoji: '🔢',
                      color: AppColors.primary,
                      route: '/arcade/number-rush',
                    ),
                    _buildGameCard(
                      context,
                      title: 'Sort It!',
                      subtitle: 'Sort numbers',
                      emoji: '📊',
                      color: AppColors.secondary,
                      route: '/arcade/sort-it',
                    ),
                    _buildGameCard(
                      context,
                      title: 'Word Builder',
                      subtitle: 'Spell words',
                      emoji: '📝',
                      color: AppColors.accent,
                      route: '/arcade/word-builder',
                    ),
                    _buildGameCard(
                      context,
                      title: 'Beat Parent',
                      subtitle: 'Challenge!',
                      emoji: '🎮',
                      color: AppColors.subjectColor('science'),
                      route: '/beat-parent/demo/1',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String emoji,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
