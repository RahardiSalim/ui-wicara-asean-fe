import 'package:flutter/material.dart';

import '../theme/wicara_colors.dart';

class SecurityNote extends StatelessWidget {
  const SecurityNote({this.maxWidth = 230, super.key});

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: WicaraColors.softMuted,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text.rich(
              TextSpan(
                text: 'Your data is private and secure.\n',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: WicaraColors.softMuted,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(
                    text: 'Learn how we protect you.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WicaraColors.periwinkle,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
