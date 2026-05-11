import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/wicara_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/language_chip.dart';
import '../../../core/widgets/wicara_logo.dart';
import 'widgets/feature_badge.dart';
import 'widgets/learning_curve_mockup.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pageWidth = math.min(constraints.maxWidth, 430.0);

            return Center(
              child: SizedBox(
                width: pageWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 14, 28, 22),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 36,
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerRight,
                          child: LanguageChip(),
                        ),
                        const SizedBox(height: 48),
                        const WicaraLogo(),
                        const SizedBox(height: 18),
                        Text(
                          'Prerequisite-first AI tutor\nfor ASEAN learners',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: WicaraColors.muted,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 34),
                        const Row(
                          children: [
                            FeatureBadge(
                              icon: Icons.insights_rounded,
                              label: 'Adapts to you',
                            ),
                            SizedBox(width: 12),
                            FeatureBadge(
                              icon: Icons.menu_book_rounded,
                              label: 'Builds\nprerequisites',
                            ),
                            SizedBox(width: 12),
                            FeatureBadge(
                              icon: Icons.public_rounded,
                              label: 'Speaks your\nlanguage',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const LearningCurveMockup(),
                        const SizedBox(height: 14),
                        const _PageIndicator(),
                        const SizedBox(height: 36),
                        GradientButton(
                          label: 'Get started',
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRoutes.signIn),
                        ),
                        const SizedBox(height: 16),
                        _SecondaryButton(
                          label: 'I already have an account',
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRoutes.signIn),
                        ),
                        const SizedBox(height: 24),
                        const _TermsCopy(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 17,
          height: 7,
          decoration: BoxDecoration(
            gradient: WicaraColors.primaryGradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 7),
        _IndicatorDot(color: WicaraColors.line),
        const SizedBox(width: 7),
        _IndicatorDot(color: WicaraColors.line.withValues(alpha: 0.82)),
      ],
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: WicaraColors.line, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: WicaraColors.muted,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: WicaraColors.muted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _TermsCopy extends StatelessWidget {
  const _TermsCopy();

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: WicaraColors.muted,
      fontWeight: FontWeight.w700,
    );
    final linkStyle = baseStyle?.copyWith(
      color: WicaraColors.periwinkle,
      fontWeight: FontWeight.w900,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(text: 'Terms', style: linkStyle),
          const TextSpan(text: ' and '),
          TextSpan(text: 'Privacy Policy.', style: linkStyle),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
