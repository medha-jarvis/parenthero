import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../providers/child_provider.dart';

/// Netflix-style avatar selector for switching between children.
class ChildSwitchWidget extends ConsumerStatefulWidget {
  const ChildSwitchWidget({
    super.key,
    required this.children,
    required this.childIds,
  });

  final List<ChildProfile> children;
  final List<String> childIds;

  @override
  ConsumerState<ChildSwitchWidget> createState() => _ChildSwitchWidgetState();
}

class _ChildSwitchWidgetState extends ConsumerState<ChildSwitchWidget> {
  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedChildIdProvider);
    final activeId = selectedId ?? (widget.childIds.isNotEmpty ? widget.childIds.first : null);

    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.children.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          final child = widget.children[index];
          final isSelected = child.id == activeId;
          return GestureDetector(
            onTap: () {
              ref.read(selectedChildIdProvider.notifier).state = child.id;
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvatarWidget(
                    name: child.name,
                    avatarIndex: child.avatarIndex,
                    size: 32,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Text(
                      child.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
