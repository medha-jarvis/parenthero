import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';

/// Sort It! - drag to sort numbers in ascending order.
class SortItGame extends StatefulWidget {
  const SortItGame({super.key});

  @override
  State<SortItGame> createState() => _SortItGameState();
}

class _SortItGameState extends State<SortItGame> {
  List<int> _numbers = [];
  List<int> _sorted = [];
  int? _draggedIndex;
  int _score = 0;
  int _round = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    final rng = Random();
    final count = min(3 + _round, 6);
    final nums = <int>{};
    while (nums.length < count) {
      nums.add(rng.nextInt(50) + 1);
    }
    setState(() {
      _numbers = nums.toList()..shuffle();
      _sorted = [];
      _draggedIndex = null;
    });
  }

  void _onDragStart(int index) {
    setState(() => _draggedIndex = index);
  }

  void _onDragEnd(int sourceIndex) {
    if (_draggedIndex == null) return;

    final number = _numbers.removeAt(sourceIndex);
    _sorted.add(number);

    // Check if sorted correctly
    final isCorrect = List.from(_sorted)
      ..sort()
      ..fold(0, (prev, curr) {
        return prev <= curr ? curr : -1;
      });

    setState(() {
      _draggedIndex = null;
    });

    if (_numbers.isEmpty) {
      // Check final order
      final sortedCopy = List.from(_sorted)..sort();
      if (_sorted.join(',') == sortedCopy.join(',')) {
        setState(() {
          _score += 10;
          _round++;
        });
      }
      if (_round >= 5) {
        setState(() => _isComplete = true);
      } else {
        _generateRound();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return _buildCompleteScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sort It!'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Score: $_score',
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Sort these numbers in ascending order',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            // Unsorted numbers
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _numbers.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _numbers.removeAt(oldIndex);
                    _numbers.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  return Card(
                    key: ValueKey(_numbers[index]),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        child: Text(
                          '${_numbers[index]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        'Tap & drag to sort',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.drag_handle_rounded),
                    ),
                  );
                },
              ),
            ),
            // Sorted display
            if (_sorted.isNotEmpty) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sorted so far:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sorted.map((n) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$n',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
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
              const Text('🏆', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 24),
              const Text(
                'Sorting Master!',
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
