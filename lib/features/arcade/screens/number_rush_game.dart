import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';

/// Number Rush - quick math game tapping correct answers.
class NumberRushGame extends StatefulWidget {
  const NumberRushGame({super.key});

  @override
  State<NumberRushGame> createState() => _NumberRushGameState();
}

class _NumberRushGameState extends State<NumberRushGame> {
  int _score = 0;
  int _timeLeft = 30;
  int _numA = 0;
  int _numB = 0;
  int _correctAnswer = 0;
  final List<int> _options = [];
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _gameOver) return;
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
        _startTimer();
      } else {
        setState(() => _gameOver = true);
      }
    });
  }

  void _generateQuestion() {
    final rng = Random();
    _numA = rng.nextInt(20) + 1;
    _numB = rng.nextInt(20) + 1;
    _correctAnswer = _numA + _numB;

    final opts = <int>{_correctAnswer};
    while (opts.length < 4) {
      opts.add(_correctAnswer + rng.nextInt(10) - 5);
    }
    _options.clear();
    _options.addAll(opts.toList()..shuffle());
  }

  void _tapAnswer(int answer) {
    if (_gameOver) return;
    if (answer == _correctAnswer) {
      setState(() => _score++);
    }
    _generateQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) {
      return _buildGameOverScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Rush'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_timeLeft s',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _timeLeft <= 10 ? AppColors.error : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Score
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            // Question
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_numA + $_numB',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _options.map((opt) {
                      return GestureDetector(
                        onTap: () => _tapAnswer(opt),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$opt',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.coolGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⏰', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 24),
              const Text(
                'Time\'s Up!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Score: $_score',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
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
                child: const Text('Done',
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
