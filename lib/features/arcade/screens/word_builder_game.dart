import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';

/// Word Builder - spell words from scrambled letters.
class WordBuilderGame extends StatefulWidget {
  const WordBuilderGame({super.key});

  @override
  State<WordBuilderGame> createState() => _WordBuilderGameState();
}

class _WordBuilderGameState extends State<WordBuilderGame> {
  final List<Map<String, dynamic>> _words = [
    {'word': 'apple', 'hint': 'A red fruit'},
    {'word': 'tiger', 'hint': 'A big striped cat'},
    {'word': 'house', 'hint': 'Where you live'},
    {'word': 'cloud', 'hint': 'White in the sky'},
    {'word': 'dance', 'hint': 'Move to music'},
    {'word': 'happy', 'hint': 'Feeling good'},
    {'word': 'smart', 'hint': 'Very clever'},
    {'word': 'brave', 'hint': 'Not afraid'},
  ];

  int _currentWord = 0;
  final List<String> _scrambled = [];
  final List<String> _userSelection = [];
  int _score = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _scrambleWord();
  }

  void _scrambleWord() {
    final word = _words[_currentWord]['word'] as String;
    final letters = word.split('')..shuffle(Random());
    // Ensure scrambled order is different from original
    if (letters.join('') == word) {
      letters.shuffle();
    }
    setState(() {
      _scrambled.clear();
      _scrambled.addAll(letters);
      _userSelection.clear();
    });
  }

  void _tapLetter(int index) {
    if (index >= _scrambled.length) return;
    setState(() {
      _userSelection.add(_scrambled.removeAt(index));
    });
  }

  void _undoLast() {
    if (_userSelection.isEmpty) return;
    setState(() {
      _scrambled.add(_userSelection.removeLast());
    });
  }

  void _checkAnswer() {
    final answer = _userSelection.join();
    final correct = _words[_currentWord]['word'] as String;

    if (answer == correct) {
      setState(() => _score += 10);
      if (_currentWord < _words.length - 1) {
        setState(() {
          _currentWord++;
        });
        _scrambleWord();
      } else {
        setState(() => _isComplete = true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not quite right! Try again.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return _buildCompleteScreen();
    }

    final wordData = _words[_currentWord];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Builder'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_score pts',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
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
            // Hint
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 32, color: AppColors.warning),
                  const SizedBox(height: 8),
                  Text(
                    wordData['hint'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // User's answer
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _userSelection.map((letter) {
                  return Container(
                    width: 32,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Center(
                      child: Text(
                        letter.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            // Scrambled letters
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Text(
                      'Tap letters in order:',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(_scrambled.length, (index) {
                        return GestureDetector(
                          onTap: () => _tapLetter(index),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.15),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _scrambled[index].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _undoLast,
                        icon: const Icon(Icons.undo_rounded),
                        label: const Text('Undo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _checkAnswer,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Check'),
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

  Widget _buildCompleteScreen() {
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
              const Text('📝', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 24),
              const Text(
                'Word Master!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Final Score: $_score',
                style: const TextStyle(
                  fontSize: 20,
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
