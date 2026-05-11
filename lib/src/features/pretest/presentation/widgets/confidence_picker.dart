import 'package:flutter/material.dart';

import '../../../../core/theme/wicara_colors.dart';

class ConfidencePicker extends StatelessWidget {
  const ConfidencePicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: WicaraColors.line),
        const SizedBox(height: 17),
        Text(
          'How confident are you?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: WicaraColors.muted,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Text(
              'Low',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: WicaraColors.softMuted,
                fontWeight: FontWeight.w900,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var score = 1; score <= 6; score++)
                    GestureDetector(
                      onTap: () => onChanged(score),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: score == value ? 18 : 8,
                        height: score == value ? 18 : 8,
                        decoration: BoxDecoration(
                          color: score == value
                              ? WicaraColors.periwinkle
                              : WicaraColors.softMuted.withValues(alpha: 0.58),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              'High',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: WicaraColors.muted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
