import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../providers/campaign_provider.dart';

/// Interactive practice pad with numeric/drawing input.
class PracticePadScreen extends ConsumerStatefulWidget {
  final String topicId;
  final int day;

  const PracticePadScreen({
    super.key,
    required this.topicId,
    required this.day,
  });

  @override
  ConsumerState<PracticePadScreen> createState() => _PracticePadScreenState();
}

class _PracticePadScreenState extends ConsumerState<PracticePadScreen> {
  final List<Map<String, dynamic>> _problems = [
    {
      'question': 'What is 5 + 3?',
      'answer': '8',
      'hint': 'Count on your fingers from 5',
    },
    {
      'question': 'What is 12 - 4?',
      'answer': '8',
      'hint': 'Take away 4 from 12',
    },
    {
      'question': 'What is 3 × 4?',
      'answer': '12',
      'hint': 'Think: 3 groups of 4',
    },
    {
      'question': 'What is 15 ÷ 3?',
      'answer': '5',
      'hint': 'How many 3s make 15?',
    },
    {
      'question': 'What is 7 + 6?',
      'answer': '13',
      'hint': '7 + 3 = 10, then add 3 more',
    },
  ];

  int _currentProblem = 0;
  final _answerController = TextEditingController();
  String? _feedback;
  bool _isCorrect = false;
  bool _showHint = false;
  int _score = 0;
  bool _isComplete = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final userAnswer = _answerController.text.trim().toLowerCase();
    final correctAnswer =
        (_problems[_currentProblem]['answer'] as String).toLowerCase();

    if (userAnswer == correctAnswer) {
      setState(() {
        _isCorrect = true;
        _feedback = 'Correct! 🎉';
        _score++;
      });
    } else {
      setState(() {
        _isCorrect = false;
        _feedback = 'Not quite. Try again! 💪';
      });
    }
  }

  void _nextProblem() {
    if (_currentProblem < _problems.length - 1) {
      setState(() {
        _currentProblem++;
        _answerController.clear();
        _feedback = null;
        _isCorrect = false;
        _showHint = false;
      });
    } else {
      setState(() => _isComplete = true);
      _markComplete();
    }
  }

  Future<void> _markComplete() async {
    final campaignAsync = ref.read(campaignProvider);
    final campaign = campaignAsync.valueOrNull;
    if (campaign != null) {
      try {
        await ref.read(campaignProvider.notifier).completeDayActivity(
              campaignId: campaign.id,
              day: widget.day,
              activity: 'practiceCompleted',
            );
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return _buildCompleteScreen();
    }

    final problem = _problems[_currentProblem];

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.practice} - Day ${widget.day}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_score/${_problems.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LinearProgressIndicator(
                value: (_currentProblem + 1) / _problems.length,
                backgroundColor: AppColors.surface,
                color: AppColors.primary,
              ),
            ),
            // Problem card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Problem ${_currentProblem + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            problem['question'] as String,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _answerController,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Your answer',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_feedback != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isCorrect
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isCorrect
                                        ? Icons.check_circle_rounded
                                        : Icons.error_outline_rounded,
                                    color: _isCorrect
                                        ? AppColors.success
                                        : AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _feedback!,
                                    style: TextStyle(
                                      color: _isCorrect
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_showHint) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline,
                                      color: AppColors.warning, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      problem['hint'] as String,
                                      style: const TextStyle(
                                        color: AppColors.warning,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_feedback == null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _showHint = !_showHint),
                              child: Text(_showHint
                                  ? 'Hide Hint'
                                  : 'Show Hint'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: AppButton(
                              label: 'Check Answer',
                              onPressed: _checkAnswer,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      AppButton(
                        label: _currentProblem < _problems.length - 1
                            ? AppStrings.next
                            : AppStrings.done,
                        onPressed: _nextProblem,
                        isGradient: _isCorrect,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.greenGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 24),
              const Text(
                'Practice Complete!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You solved $_score out of ${_problems.length} problems correctly!',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.success,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => context.pop(),
                child: const Text(
                  AppStrings.done,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
