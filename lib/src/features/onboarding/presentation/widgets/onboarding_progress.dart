import 'package:flutter/material.dart';

import '../../../../core/theme/wicara_colors.dart';

class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    required this.currentStep,
    this.totalSteps = 3,
    super.key,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var step = 1; step <= totalSteps; step++) ...[
          _StepCircle(step: step, isActive: step == currentStep),
          if (step < totalSteps)
            Container(width: 58, height: 1.5, color: WicaraColors.line),
        ],
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.step, required this.isActive});

  final int step;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        color: isActive ? WicaraColors.secondary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? Colors.transparent : WicaraColors.line,
          width: 1.5,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: WicaraColors.secondary.withValues(alpha: 0.24),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$step',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isActive ? Colors.white : WicaraColors.softMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
