import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../providers/campaign_provider.dart';

/// Teaching script screen with animated slides and swipe gestures.
class TeachingScriptScreen extends ConsumerStatefulWidget {
  final String topicId;
  final int day;

  const TeachingScriptScreen({
    super.key,
    required this.topicId,
    required this.day,
  });

  @override
  ConsumerState<TeachingScriptScreen> createState() =>
      _TeachingScriptScreenState();
}

class _TeachingScriptScreenState extends ConsumerState<TeachingScriptScreen> {
  final _pageController = PageController();
  int _currentSlide = 0;
  bool _isCompleted = false;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Welcome!',
      'content': 'Today we are going to learn something amazing!',
      'emoji': '🌟',
      'color': AppColors.primary,
    },
    {
      'title': 'Key Concept',
      'content': 'Let\'s understand the main idea first.\n\nEverything starts with understanding the basics. Take your time and read carefully!',
      'emoji': '💡',
      'color': AppColors.secondary,
    },
    {
      'title': 'Let\'s Try!',
      'content': 'Here\'s an example to help you understand better.\n\nFollow along and see how it works step by step.',
      'emoji': '✏️',
      'color': AppColors.accent,
    },
    {
      'title': 'Great Job!',
      'content': 'You\'ve learned the key concepts! Now let\'s practice what we learned.',
      'emoji': '🎉',
      'color': AppColors.primary,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTeachingContent();
  }

  Future<void> _loadTeachingContent() async {
    // In production, load from Firestore via campaign notifier
  }

  Future<void> _completeAndGoNext() async {
    setState(() => _isCompleted = true);

    // Mark as completed in campaign
    final campaignAsync = ref.read(campaignProvider);
    final campaign = campaignAsync.valueOrNull;
    if (campaign != null) {
      try {
        await ref.read(campaignProvider.notifier).completeDayActivity(
              campaignId: campaign.id,
              day: widget.day,
              activity: 'scriptWatched',
            );
      } catch (_) {}
    }

    if (!mounted) return;
    context.pop();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            // Swipe left - next
            if (_currentSlide < _slides.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          } else if (details.primaryVelocity! > 0) {
            // Swipe right - previous
            if (_currentSlide > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        },
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _currentSlide = i),
          itemCount: _slides.length,
          itemBuilder: (context, index) {
            final slide = _slides[index];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    slide['color'] as Color,
                    (slide['color'] as Color).withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                          const Spacer(),
                          Text(
                            '${_currentSlide + 1} / ${_slides.length}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentSlide + 1) / _slides.length,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.2),
                          color: Colors.white,
                          minHeight: 4,
                        ),
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              slide['emoji'] as String,
                              style: const TextStyle(fontSize: 72),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              slide['title'] as String,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              slide['content'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom button
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: slide['color'] as Color,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              if (_currentSlide < _slides.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _completeAndGoNext();
                              }
                            },
                            child: Text(
                              _currentSlide < _slides.length - 1
                                  ? AppStrings.next
                                  : AppStrings.done,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
