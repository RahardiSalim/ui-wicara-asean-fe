import 'package:flutter/material.dart';

import '../../../../core/theme/wicara_colors.dart';

class FeatureBadge extends StatelessWidget {
  const FeatureBadge({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: WicaraColors.shadowBlue.withValues(alpha: 0.24),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: WicaraColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
