import 'package:flutter/material.dart';

import '../../../../core/theme/wicara_colors.dart';

class PreferenceCallout extends StatelessWidget {
  const PreferenceCallout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: WicaraColors.periwinkle,
              size: 17,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'WICARA adapts to you, your pace, your style,\nand your goals.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: WicaraColors.periwinkle,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
