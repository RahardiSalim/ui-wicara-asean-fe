import 'package:flutter/material.dart';

import '../../../../core/theme/wicara_colors.dart';

class FishboneCanvas extends StatelessWidget {
  const FishboneCanvas({
    required this.isExpanded,
    required this.onToggleExpanded,
    super.key,
  });

  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 180),
      crossFadeState: isExpanded
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Container(
        height: 308,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WicaraColors.line, width: 1.3),
          boxShadow: [
            BoxShadow(
              color: WicaraColors.shadowBlue.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Expanded(
              child: CustomPaint(
                painter: _FishbonePainter(),
                child: SizedBox.expand(),
              ),
            ),
            const Divider(height: 1, color: WicaraColors.line),
            _CanvasToolbar(onToggleExpanded: onToggleExpanded),
          ],
        ),
      ),
      secondChild: _CollapsedCanvas(onToggleExpanded: onToggleExpanded),
    );
  }
}

class _CollapsedCanvas extends StatelessWidget {
  const _CollapsedCanvas({required this.onToggleExpanded});

  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggleExpanded,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: WicaraColors.line, width: 1.3),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.draw_outlined,
                color: WicaraColors.periwinkle,
                size: 20,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Canvas collapsed',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: WicaraColors.muted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_up_rounded,
                color: WicaraColors.softMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CanvasToolbar extends StatelessWidget {
  const _CanvasToolbar({required this.onToggleExpanded});

  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Row(
        children: [
          _ToolButton(
            icon: Icons.edit_outlined,
            isActive: true,
            onPressed: () {},
          ),
          _ToolButton(icon: Icons.circle_outlined, onPressed: () {}),
          _ToolButton(icon: Icons.text_fields_rounded, onPressed: () {}),
          _ToolButton(icon: Icons.image_outlined, onPressed: () {}),
          const Spacer(),
          _ToolButton(icon: Icons.undo_rounded, onPressed: () {}),
          _ToolButton(icon: Icons.redo_rounded, onPressed: () {}),
          _ToolButton(
            icon: Icons.keyboard_arrow_down_rounded,
            onPressed: onToggleExpanded,
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 43,
      height: 54,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: 22,
        color: isActive ? WicaraColors.periwinkle : WicaraColors.softMuted,
        tooltip: '',
      ),
    );
  }
}

class _FishbonePainter extends CustomPainter {
  const _FishbonePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = WicaraColors.periwinkle.withValues(alpha: 0.9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final sketch = Paint()
      ..color = WicaraColors.softMuted.withValues(alpha: 0.62)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final y = size.height * 0.58;
    final start = Offset(size.width * 0.23, y);
    final end = Offset(size.width * 0.80, y);
    canvas.drawLine(start, end, ink);
    _drawArrowHead(canvas, end, ink);

    _drawBone(canvas, Offset(size.width * 0.38, y), -1, sketch);
    _drawBone(canvas, Offset(size.width * 0.58, y), -1, sketch);
    _drawBone(canvas, Offset(size.width * 0.43, y), 1, sketch);
    _drawBone(canvas, Offset(size.width * 0.62, y), 1, sketch);

    _drawLabel(canvas, 'Method', Offset(size.width * 0.31, size.height * 0.17));
    _drawLabel(
      canvas,
      'Machine',
      Offset(size.width * 0.55, size.height * 0.17),
    );
    _drawLabel(
      canvas,
      'Material',
      Offset(size.width * 0.32, size.height * 0.82),
    );
    _drawLabel(
      canvas,
      'Manpower',
      Offset(size.width * 0.54, size.height * 0.82),
    );
    _drawLabel(
      canvas,
      'Process\nChange',
      Offset(size.width * 0.12, size.height * 0.50),
      align: TextAlign.left,
    );
    _drawLabel(
      canvas,
      'Increased\nDefects',
      Offset(size.width * 0.82, size.height * 0.50),
      align: TextAlign.left,
    );
  }

  void _drawBone(Canvas canvas, Offset joint, int direction, Paint paint) {
    final end = Offset(joint.dx - 31, joint.dy + direction * 78);
    canvas.drawLine(joint, end, paint);
    canvas.drawLine(
      Offset(end.dx + 6, end.dy - direction * 24),
      Offset(end.dx + 30, end.dy - direction * 24),
      paint,
    );
    canvas.drawLine(
      Offset(end.dx + 15, end.dy - direction * 48),
      Offset(end.dx + 39, end.dy - direction * 48),
      paint,
    );
  }

  void _drawArrowHead(Canvas canvas, Offset end, Paint paint) {
    canvas.drawLine(end, Offset(end.dx - 10, end.dy - 7), paint);
    canvas.drawLine(end, Offset(end.dx - 10, end.dy + 7), paint);
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset offset, {
    TextAlign align = TextAlign.center,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: WicaraColors.text,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: 72);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
