import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../providers/campaign_provider.dart';

/// MCQ quiz screen with difficulty levels, timer, and score animation.
class QuizScreen extends ConsumerStatefulWidget {
  final String topicId;
  final int day;

  const QuizScreen({
    super.key,
    required this.topicId,
    required this.day,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is 5 + 3?',
      'options': ['6', '7', '8', '9'],
      'correctIndex': 2,
      'difficulty': 1,
    },
    {
      'question': 'Which shape has 4 equal sides?',
      'options': ['Triangle', 'Square', 'Circle', 'Rectangle'],
      'correctIndex': 1,
      'difficulty': 1,
    },
    {
      'question': 'What is 12 × 3?',
      'options': ['24', '36', '48', '15'],
      'correctIndex': 1,
      'difficulty': 2,
    },
    {
      'question': 'What is 3/4 as a decimal?',
      'options': ['0.25', '0.5', '0.75', '1.0'],
      'correctIndex': 2,
      'difficulty': 3,
    },
    {
      'question': 'If a triangle has angles 60° and 70°, what is the third angle?',
      'options': ['40°', '50°', '60°', '70°'],
      'correctIndex': 1,
      'difficulty': 3,
    },
    {
      'question': 'What is the perimeter of a square with side 5 cm?',
      'options': ['10 cm', '15 cm', '20 cm', '25 cm'],
      'correctIndex': 2,
      'difficulty': 2,
    },
    {
      'question': 'Which number is prime?',
      'options': ['15', '21', '23', '27'],
      'correctIndex': 2,
      'difficulty': 2,
    },
    {
      'question': 'What is 100 ÷ 4?',
      'options': ['20', '25', '40', '50'],
      'correctIndex': 1,
      'difficulty': 1,
    },
  ];

  int _currentQuestion = 0;
  int? _selectedIndex;
  bool _isAnswered = false;
  int _score = 0;
  late AnimationController _scoreAnimController;
  late Animation<double> _scoreAnim;

  // Timer
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scoreAnim = CurvedAnimation(
      parent: _scoreAnimController,
      curve: Curves.elasticOut,
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
      _selectedIndex = -1; // timeout indicator
    });
    _nextQuestion();
  }

  void _selectAnswer(int index) {
    if (_isAnswered) return;
    _timer?.cancel();

    final isCorrect = index == _questions[_currentQuestion]['correctIndex'];
    setState(() {
      _selectedIndex = index;
      _isAnswered = true;
      if (isCorrect) {
        _score++;
        _scoreAnimController.forward(from: 0);
      }
    });

    Future.delayed(const Duration(milliseconds: 800), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedIndex = null;
        _isAnswered = false;
      });
      _startTimer();
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
              activity: 'quizCompleted',
              quizScore: _score,
              quizMax: _questions.length,
            );
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scoreAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return _buildCompleteScreen();
    }

    final question = _questions[_currentQuestion];
    final isCorrect = _selectedIndex != null &&
        _selectedIndex == question['correctIndex'];
    final isWrong = _selectedIndex != null &&
        _selectedIndex != -1 &&
        _selectedIndex != question['correctIndex'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.quizTime} - Day ${widget.day}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _secondsRemaining <= 10
                      ? AppColors.error.withValues(alpha: 0.15)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: _secondsRemaining <= 10
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _secondsRemaining.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: _secondsRemaining <= 10
                            ? AppColors.error
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppStrings.question} ${_currentQuestion + 1} ${AppStrings.of} ${_questions.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Score: $_score',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentQuestion + 1) / _questions.length,
                    backgroundColor: AppColors.surface,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            // Timer bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _secondsRemaining / 30,
                  backgroundColor:
                      AppColors.error.withValues(alpha: 0.1),
                  color: _secondsRemaining <= 10
                      ? AppColors.error
                      : AppColors.secondary,
                  minHeight: 4,
                ),
              ),
            ),
            // Question
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Difficulty badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Difficulty: ${"⭐" * (question['difficulty'] as int)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      question['question'] as String,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Options
                    ...List.generate(
                      (question['options'] as List).length,
                      (index) => _buildOption(
                        (question['options'] as List)[index] as String,
                        index,
                        question['correctIndex'] as int,
                      ),
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

  Widget _buildOption(String text, int index, int correctIndex) {
    Color bgColor = AppColors.cardBackground;
    Color textColor = AppColors.textPrimary;
    IconData? icon;
    Color iconColor = Colors.transparent;

    if (_isAnswered) {
      if (index == correctIndex) {
        bgColor = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
      } else if (index == _selectedIndex) {
        bgColor = AppColors.error.withValues(alpha: 0.12);
        textColor = AppColors.error;
        icon = Icons.cancel_rounded;
        iconColor = AppColors.error;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _selectAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isAnswered && index == _selectedIndex
                  ? textColor
                  : AppColors.divider,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, color: iconColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteScreen() {
    final percentage = (_score / _questions.length) * 100;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: percentage >= 60
              ? AppColors.greenGradient
              : AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scoreAnim,
                child: Text(
                  percentage >= 80
                      ? '🏆'
                      : percentage >= 60
                          ? '🎉'
                          : '💪',
                  style: const TextStyle(fontSize: 80),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                percentage >= 80
                    ? AppStrings.greatJob
                    : percentage >= 60
                        ? AppStrings.quizComplete
                        : AppStrings.keepPracticing,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${AppStrings.yourScore}: $_score / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentage.toInt()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => context.pop(),
                child: const Text(
                  AppStrings.done,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
