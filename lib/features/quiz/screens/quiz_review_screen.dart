import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';

/// Quiz review screen showing all answers with correct/incorrect indicators.
class QuizReviewScreen extends StatelessWidget {
  final String topicId;
  final int day;

  const QuizReviewScreen({
    super.key,
    required this.topicId,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    // Demo data - in production, load from provider/state
    final reviewItems = [
      {'question': 'What is 5 + 3?', 'yourAnswer': '8', 'correctAnswer': '8', 'isCorrect': true},
      {'question': 'Which shape has 4 equal sides?', 'yourAnswer': 'Rectangle', 'correctAnswer': 'Square', 'isCorrect': false},
      {'question': 'What is 12 × 3?', 'yourAnswer': '36', 'correctAnswer': '36', 'isCorrect': true},
      {'question': 'What is 3/4 as a decimal?', 'yourAnswer': '0.75', 'correctAnswer': '0.75', 'isCorrect': true},
      {'question': 'What is the perimeter of a square with side 5 cm?', 'yourAnswer': '20 cm', 'correctAnswer': '20 cm', 'isCorrect': true},
    ];

    final correctCount = reviewItems.where((i) => i['isCorrect'] as bool).length;
    final totalCount = reviewItems.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.quizComplete),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Score summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Column(
                children: [
                  const Text(
                    'Review Answers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$correctCount / $totalCount correct',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Review list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reviewItems.length,
                itemBuilder: (context, index) {
                  final item = reviewItems[index];
                  final isCorrect = item['isCorrect'] as bool;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCorrect
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: isCorrect
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Question ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['question'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Your answer: ${item['yourAnswer']}',
                                style: TextStyle(
                                  color: isCorrect
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!isCorrect)
                          Text(
                            'Correct answer: ${item['correctAnswer']}',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
