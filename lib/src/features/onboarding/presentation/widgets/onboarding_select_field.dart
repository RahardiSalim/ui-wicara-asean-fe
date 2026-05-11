import 'package:flutter/material.dart';

import '../../../../core/theme/wicara_colors.dart';

class OnboardingSelectField extends StatelessWidget {
  const OnboardingSelectField({
    required this.label,
    required this.value,
    required this.leading,
    this.showChevron = true,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final Widget leading;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: WicaraColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 54,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: WicaraColors.fieldFill,
                border: Border.all(color: WicaraColors.line, width: 1.4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  SizedBox(width: 25, child: Center(child: leading)),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: WicaraColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (showChevron)
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: WicaraColors.softMuted,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IndonesiaFlag extends StatelessWidget {
  const IndonesiaFlag({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        width: 24,
        height: 16,
        decoration: BoxDecoration(border: Border.all(color: WicaraColors.line)),
        child: Column(
          children: [
            Expanded(child: Container(color: const Color(0xFFD83732))),
            Expanded(child: Container(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
