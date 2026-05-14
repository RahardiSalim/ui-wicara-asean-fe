import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/wicara_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/wicara_logo.dart';

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
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const WicaraLogo(width: 350),
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
                          const SizedBox(height: 36),
                          GradientButton(
                            label: 'Get started',
                            onPressed: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.signIn),
                          ),
                          const SizedBox(height: 16),
                          _SecondaryButton(
                            label: 'I already have an account',
                            onPressed: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.signIn),
                          ),
                        ],
                      ),
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
