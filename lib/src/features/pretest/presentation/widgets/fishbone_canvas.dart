import 'package:flutter/material.dart';

import '../../../../core/theme/wicara_colors.dart';

class FishboneCanvas extends StatefulWidget {
  const FishboneCanvas({
    this.height = 336,
    this.isLargePanel = false,
    this.onOpenLargePanel,
    super.key,
  });

  final double height;
  final bool isLargePanel;
  final VoidCallback? onOpenLargePanel;

  @override
  State<FishboneCanvas> createState() => _FishboneCanvasState();
}

class _FishboneCanvasState extends State<FishboneCanvas> {
  final List<List<Offset>> _strokes = [];
  final List<List<Offset>> _redoStack = [];
  bool _hasAttachment = false;

  void _startStroke(DragStartDetails details) {
    setState(() {
      _redoStack.clear();
      _strokes.add([details.localPosition]);
    });
  }

  void _extendStroke(DragUpdateDetails details) {
    setState(() => _strokes.last.add(details.localPosition));
  }

  void _undo() {
    if (_strokes.isEmpty) {
      return;
    }
    setState(() => _redoStack.add(_strokes.removeLast()));
  }

  void _redo() {
    if (_redoStack.isEmpty) {
      return;
    }
    setState(() => _strokes.add(_redoStack.removeLast()));
  }

  void _attachImage() {
    setState(() => _hasAttachment = true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Canvas',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Draw your work or upload paper notes as context.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: WicaraColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onOpenLargePanel != null)
                  IconButton(
                    tooltip: widget.isLargePanel
                        ? 'Close panel'
                        : 'Larger panel',
                    onPressed: widget.onOpenLargePanel,
                    icon: Icon(
                      widget.isLargePanel
                          ? Icons.close_fullscreen_rounded
                          : Icons.open_in_full_rounded,
                      color: WicaraColors.secondary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _CanvasToolButton(
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  onPressed: _strokes.isEmpty ? null : _undo,
                ),
                const SizedBox(width: 8),
                _CanvasToolButton(
                  icon: Icons.redo_rounded,
                  label: 'Redo',
                  onPressed: _redoStack.isEmpty ? null : _redo,
                ),
                const SizedBox(width: 8),
                _CanvasToolButton(
                  icon: Icons.upload_file_rounded,
                  label: 'Upload image',
                  onPressed: _attachImage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: GestureDetector(
                onPanStart: _startStroke,
                onPanUpdate: _extendStroke,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFCFF),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: WicaraColors.secondary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: CustomPaint(
                    painter: _WorkCanvasPainter(
                      strokes: _strokes,
                      hasAttachment: _hasAttachment,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CanvasToolButton extends StatelessWidget {
  const _CanvasToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isEnabled
              ? WicaraColors.secondary
              : WicaraColors.softMuted,
          side: BorderSide(
            color: isEnabled
                ? WicaraColors.secondary.withValues(alpha: 0.32)
                : WicaraColors.line,
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isEnabled ? WicaraColors.secondary : WicaraColors.softMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _WorkCanvasPainter extends CustomPainter {
  const _WorkCanvasPainter({
    required this.strokes,
    required this.hasAttachment,
  });

  final List<List<Offset>> strokes;
  final bool hasAttachment;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = WicaraColors.primary.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (var x = 24.0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 24.0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (hasAttachment) {
      final paperRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.12, 132, 88),
        const Radius.circular(12),
      );
      final paperPaint = Paint()
        ..color = WicaraColors.secondarySoft.withValues(alpha: 0.68);
      canvas.drawRRect(paperRect, paperPaint);
      _drawText(
        canvas,
        'Paper work\nattached',
        Offset(size.width * 0.08 + 18, size.height * 0.12 + 24),
        WicaraColors.secondaryDeep,
      );
    }

    if (strokes.isEmpty && !hasAttachment) {
      _drawText(
        canvas,
        'Sketch formulas, diagrams, or working steps here.',
        Offset(size.width * 0.10, size.height * 0.46),
        WicaraColors.softMuted,
        maxWidth: size.width * 0.80,
      );
    }

    final ink = Paint()
      ..color = WicaraColors.secondaryDeep
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) {
        canvas.drawCircle(stroke.first, 2, ink);
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, ink);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    double maxWidth = 140,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _WorkCanvasPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.hasAttachment != hasAttachment;
  }
}
