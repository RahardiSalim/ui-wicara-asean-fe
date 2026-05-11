import 'package:flutter/material.dart';

import '../../../../core/theme/wicara_colors.dart';

class LearningCurveMockup extends StatelessWidget {
  const LearningCurveMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 224,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: WicaraColors.pageBackground.withValues(alpha: 0.74),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const CustomPaint(painter: _LearningCurvePainter()),
            ),
          ),
          const Positioned(
            top: 24,
            left: 22,
            child: _SpeechBubble(
              text: 'สวัสดี',
              background: WicaraColors.speechBlue,
              tail: _BubbleTail.right,
            ),
          ),
          const Positioned(
            top: 82,
            left: 0,
            child: _SpeechBubble(
              text: 'Xin chao',
              background: WicaraColors.glowPeach,
              tail: _BubbleTail.none,
            ),
          ),
          const Positioned(
            top: 74,
            right: 0,
            child: _SpeechBubble(
              text: 'Bahasa',
              background: WicaraColors.glowLilac,
              tail: _BubbleTail.left,
            ),
          ),
          const Positioned(
            bottom: 42,
            right: 38,
            child: _SpeechBubble(
              text: 'Kumusta',
              background: WicaraColors.speechGreen,
              tail: _BubbleTail.center,
            ),
          ),
          Positioned(
            right: 92,
            top: 30,
            child: Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: WicaraColors.glowLemon,
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: WicaraColors.secondary.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: WicaraColors.accentAmber,
                size: 20,
              ),
            ),
          ),
          Positioned(
            bottom: 38,
            left: 66,
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: WicaraColors.secondary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: WicaraColors.secondary.withValues(alpha: 0.26),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_graph_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _BubbleTail { none, left, right, center }

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.text,
    required this.background,
    required this.tail,
  });

  final String text;
  final Color background;
  final _BubbleTail tail;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(color: background, tail: tail),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: WicaraColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter({required this.color, required this.tail});

  final Color color;
  final _BubbleTail tail;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height - 4);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(17)));

    if (tail != _BubbleTail.none) {
      final tailX = switch (tail) {
        _BubbleTail.left => size.width * 0.25,
        _BubbleTail.right => size.width * 0.72,
        _BubbleTail.center => size.width * 0.5,
        _BubbleTail.none => size.width * 0.5,
      };
      path
        ..moveTo(tailX - 7, size.height - 5)
        ..lineTo(tailX + 6, size.height - 5)
        ..lineTo(tailX + 1, size.height)
        ..close();
    }

    canvas.drawShadow(
      path,
      WicaraColors.shadowBlue.withValues(alpha: 0.34),
      10,
      true,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.tail != tail;
  }
}

class _LearningCurvePainter extends CustomPainter {
  const _LearningCurvePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * 0.52;
    final chartBottom = size.height * 0.78;
    final barWidth = size.width * 0.11;
    final gap = size.width * 0.035;
    final heights = [
      size.height * 0.34,
      size.height * 0.47,
      size.height * 0.58,
      size.height * 0.69,
    ];

    final shadowPaint = Paint()
      ..color = WicaraColors.shadowBlue.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    final barPaints = [
      Paint()..color = WicaraColors.primarySoft.withValues(alpha: 0.76),
      Paint()..color = WicaraColors.glowLilac.withValues(alpha: 0.7),
      Paint()..color = WicaraColors.glowPeach.withValues(alpha: 0.78),
      Paint()..color = WicaraColors.glowMint.withValues(alpha: 0.82),
    ];

    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, chartBottom - size.height * 0.2),
        width: size.width * 0.54,
        height: size.height * 0.46,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(shadowRect, shadowPaint);

    final startX = centerX - ((barWidth * 4 + gap * 3) / 2);
    for (var i = 0; i < heights.length; i++) {
      final left = startX + i * (barWidth + gap);
      final rect = Rect.fromLTWH(
        left,
        chartBottom - heights[i],
        barWidth,
        heights[i],
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)),
        barPaints[i],
      );
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = WicaraColors.secondary.withValues(alpha: 0.72);

    final path = Path()
      ..moveTo(size.width * 0.14, size.height * 0.75)
      ..cubicTo(
        size.width * 0.32,
        size.height * 0.74,
        size.width * 0.51,
        size.height * 0.61,
        size.width * 0.62,
        size.height * 0.52,
      )
      ..cubicTo(
        size.width * 0.73,
        size.height * 0.43,
        size.width * 0.81,
        size.height * 0.29,
        size.width * 0.88,
        size.height * 0.16,
      );

    canvas.drawPath(path, linePaint);

    final points = [
      Offset(size.width * 0.36, size.height * 0.67),
      Offset(size.width * 0.53, size.height * 0.55),
      Offset(size.width * 0.68, size.height * 0.42),
      Offset(size.width * 0.84, size.height * 0.21),
    ];
    final dotFill = Paint()..color = Colors.white;
    final dotStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = WicaraColors.secondary.withValues(alpha: 0.78);

    for (final point in points) {
      canvas.drawCircle(point, 6, dotFill);
      canvas.drawCircle(point, 6, dotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
