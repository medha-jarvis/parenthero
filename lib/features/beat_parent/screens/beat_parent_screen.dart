import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../providers/campaign_provider.dart';

/// Turn-based "Beat the Parent" game.
class BeatParentScreen extends ConsumerStatefulWidget {
  final String topicId;
  final int day;

  const BeatParentScreen({
    super.key,
    required this.topicId,
    required this.day,
  });

  @override
  ConsumerState<BeatParentScreen> createState() => _BeatParentScreenState();
}

class _BeatParentScreenState extends ConsumerState<BeatParentScreen>
    with SingleTickerProviderStateMixin {
  bool _isKidsTurn = true;
  int _kidScore = 0;
  int _parentScore = 0;
  int _currentRound = 0;
  final int _maxRounds = 5;
  int _randNumA = 0;
  int _randNumB = 0;
  String _operator = '+';
  int _correctAnswer = 0;
  int? _selectedAnswer;
  bool _isAnswered = false;
  bool _isGameOver = false;
  late AnimationController _animController;
  late Animation<double> _bounceAnim;

  final List<String> _operators = ['+', '-', '×'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _generateQuestion();
  }

  void _generateQuestion() {
    final rng = Random();
    _randNumA = rng.nextInt(20) + 1;
    _randNumB = rng.nextInt(20) + 1;
    _operator = _operators[rng.nextInt(_operators.length)];

    if (_operator == '+') {
      _correctAnswer = _randNumA + _randNumB;
    } else if (_operator == '-') {
      if (_randNumA < _randNumB) {
        // Swap to keep positive result
        final temp = _randNumA;
        _randNumA = _randNumB;
        _randNumB = temp;
      }
      _correctAnswer = _randNumA - _randNumB;
    } else {
      // ×
      _randNumA = rng.nextInt(10) + 1;
      _randNumB = rng.nextInt(10) + 1;
      _correctAnswer = _randNumA * _randNumB;
    }

    setState(() {
      _selectedAnswer = null;
      _isAnswered = false;
    });
  }

  List<int> _generateOptions() {
    final options = <int>{_correctAnswer};
    final rng = Random();
    while (options.length < 4) {
      options.add(_correctAnswer + rng.nextInt(10) - 5);
    }
    return options.toList()..shuffle();
  }

  void _answer(int answer) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      _animController.forward(from: 0);

      final isCorrect = answer == _correctAnswer;
      if (_isKidsTurn && isCorrect) {
        _kidScore++;
      } else if (!_isKidsTurn && isCorrect) {
        _parentScore++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_currentRound < _maxRounds - 1) {
        setState(() {
          if (!_isKidsTurn) {
            _currentRound++;
          }
          _isKidsTurn = !_isKidsTurn;
        });
        _generateQuestion();
      } else {
        setState(() => _isGameOver = true);
        _markComplete();
      }
    });
  }

  Future<void> _markComplete() async {
    final campaignAsync = ref.read(campaignProvider);
    final campaign = campaignAsync.valueOrNull;
    if (campaign != null) {
      try {
        await ref.read(campaignProvider.notifier).completeDayActivity(
              campaignId: campaign.id,
              day: widget.day,
              activity: 'beatParentCompleted',
            );
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameOver) {
      return _buildGameOverScreen();
    }

    final options = _generateOptions();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.beatTheParent),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scoreboard
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('👶 Kid',
                            style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          '$_kidScore',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: _isKidsTurn
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Round ${_currentRound + 1}/$_maxRounds',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('👩 Parent',
                            style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          '$_parentScore',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: !_isKidsTurn
                                ? AppColors.accent
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Turn indicator
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isKidsTurn
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isKidsTurn ? "👶 Kid's Turn!" : "👩 Parent's Turn!",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _isKidsTurn
                      ? AppColors.primary
                      : AppColors.accent,
                ),
              ),
            ),
            // Question
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _bounceAnim,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1 + (_bounceAnim.value * 0.1),
                        child: child,
                      );
                    },
                    child: Text(
                      '$_randNumA $_operator $_randNumB = ?',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: options.map((option) {
                      final isSelected = _selectedAnswer == option;
                      final isCorrect = option == _correctAnswer;
                      Color bgColor = AppColors.cardBackground;
                      if (_isAnswered && isSelected) {
                        bgColor = isCorrect
                            ? AppColors.success
                            : AppColors.error;
                      } else if (_isAnswered && isCorrect) {
                        bgColor = AppColors.success.withValues(alpha: 0.3);
                      }

                      return GestureDetector(
                        onTap: () => _answer(option),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? (isCorrect
                                      ? AppColors.success
                                      : AppColors.error)
                                  : AppColors.divider,
                              width: 2,
                            ),
                            boxShadow: [
                              if (!_isAnswered)
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.15),
                                  blurRadius: 8,
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$option',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: _isAnswered && isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final kidWon = _kidScore > _parentScore;
    final isTie = _kidScore == _parentScore;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: kidWon
              ? AppColors.greenGradient
              : isTie
                  ? AppColors.coolGradient
                  : AppColors.accentGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _bounceAnim,
                child: Text(
                  kidWon ? '🏆' : isTie ? '🤝' : '💪',
                  style: const TextStyle(fontSize: 80),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                kidWon
                    ? 'You Beat the Parent!'
                    : isTie
                        ? "It's a Tie!"
                        : 'Good Try!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Kid: $_kidScore  |  Parent: $_parentScore',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
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
                child: const Text(AppStrings.done,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
