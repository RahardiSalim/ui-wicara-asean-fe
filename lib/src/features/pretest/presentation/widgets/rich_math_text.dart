import 'package:flutter/material.dart';

import '../../../../core/theme/wicara_colors.dart';

class RichMathText extends StatelessWidget {
  const RichMathText(
    this.text, {
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        style ?? DefaultTextStyle.of(context).style.copyWith(height: 1.3);
    return Text.rich(
      TextSpan(children: _spans(text, baseStyle)),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

List<InlineSpan> _spans(String text, TextStyle baseStyle) {
  final spans = <InlineSpan>[];
  final formulaRegex = RegExp(
    r'(\$\$.*?\$\$|\$.*?\$|\\\(.*?\\\)|\\\[.*?\\\]|\\begin\{(?:bmatrix|pmatrix|matrix)\}.*?\\end\{(?:bmatrix|pmatrix|matrix)\})',
    dotAll: true,
  );
  var cursor = 0;
  for (final match in formulaRegex.allMatches(text)) {
    if (match.start > cursor) {
      spans.addAll(_markdownSpans(text.substring(cursor, match.start), baseStyle));
    }
    spans.addAll(_formulaSpans(match.group(0) ?? '', baseStyle));
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.addAll(_markdownSpans(text.substring(cursor), baseStyle));
  }
  return spans;
}

List<InlineSpan> _markdownSpans(String text, TextStyle baseStyle) {
  final spans = <InlineSpan>[];
  final boldRegex = RegExp(r'\*\*(.+?)\*\*');
  var cursor = 0;
  for (final match in boldRegex.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, match.start), style: baseStyle));
    }
    spans.add(
      TextSpan(
        text: match.group(1) ?? '',
        style: baseStyle.copyWith(fontWeight: FontWeight.w800),
      ),
    );
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
  }
  return spans;
}

List<InlineSpan> _formulaSpans(String value, TextStyle baseStyle) {
  final formula = _stripFormulaDelimiters(value);
  final matrixMatches = _parseMatrices(formula);
  if (matrixMatches.isEmpty) {
    return [_plainFormulaSpan(formula, baseStyle)];
  }

  final spans = <InlineSpan>[];
  var cursor = 0;
  for (final matrix in matrixMatches) {
    if (matrix.start > cursor) {
      final prefix = formula.substring(cursor, matrix.start).trim();
      if (prefix.isNotEmpty) {
        spans.add(_plainFormulaSpan(prefix, baseStyle));
      }
    }
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: _MatrixExpression(
            matrix: matrix,
            style: baseStyle.copyWith(
              color: WicaraColors.primaryDeep,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
    cursor = matrix.end;
  }
  if (cursor < formula.length) {
    final suffix = formula.substring(cursor).trim();
    if (suffix.isNotEmpty) {
      spans.add(_plainFormulaSpan(suffix, baseStyle));
    }
  }
  return spans;
}

TextSpan _plainFormulaSpan(String formula, TextStyle baseStyle) {
  return TextSpan(
    text: _formatFormula(formula),
    style: baseStyle.copyWith(
      color: WicaraColors.primaryDeep,
      fontFamily: 'monospace',
      fontWeight: FontWeight.w800,
      backgroundColor: WicaraColors.primarySoft.withValues(alpha: 0.55),
    ),
  );
}

String _formatFormula(String value) {
  var text = value.trim();
  text = text.replaceAllMapped(
    RegExp(r'\\frac\{([^{}]+)\}\{([^{}]+)\}'),
    (match) => '${match.group(1)}/${match.group(2)}',
  );
  text = text
      .replaceAll(r'\to', '→')
      .replaceAll(r'\times', '×')
      .replaceAll(r'\cdot', '·')
      .replaceAll(r'\lim', 'lim')
      .replaceAll(r'\sqrt', 'sqrt')
      .replaceAll('{', '')
      .replaceAll('}', '')
      .replaceAll('\\', '');
  return text.replaceAllMapped(
    RegExp(r'([=+\-×/→,()])'),
    (match) => '${match.group(1)}\u200B',
  );
}

String _stripFormulaDelimiters(String value) {
  var text = value.trim();
  if (text.startsWith(r'$$') && text.endsWith(r'$$') && text.length >= 4) {
    return text.substring(2, text.length - 2).trim();
  }
  if (text.startsWith(r'$') && text.endsWith(r'$') && text.length >= 2) {
    return text.substring(1, text.length - 1).trim();
  }
  if (text.startsWith(r'\(') && text.endsWith(r'\)') && text.length >= 4) {
    return text.substring(2, text.length - 2).trim();
  }
  if (text.startsWith(r'\[') && text.endsWith(r'\]') && text.length >= 4) {
    return text.substring(2, text.length - 2).trim();
  }
  return text;
}

List<_ParsedMatrix> _parseMatrices(String formula) {
  final regex = RegExp(
    r'\\begin\{(bmatrix|pmatrix|matrix)\}(.+?)\\end\{\1\}',
    dotAll: true,
  );
  final matrices = <_ParsedMatrix>[];
  for (final match in regex.allMatches(formula)) {
    final environment = match.group(1) ?? 'matrix';
    final body = match.group(2) ?? '';
    final rows = body
        .split(RegExp(r'\\\\'))
        .map(
          (row) => row
              .split('&')
              .map((cell) => _formatFormula(cell.trim()))
              .where((cell) => cell.isNotEmpty)
              .toList(growable: false),
        )
        .where((row) => row.isNotEmpty)
        .toList(growable: false);
    if (rows.isEmpty) {
      continue;
    }
    matrices.add(
      _ParsedMatrix(
        environment: environment,
        rows: rows,
        start: match.start,
        end: match.end,
      ),
    );
  }
  return matrices;
}

class _ParsedMatrix {
  const _ParsedMatrix({
    required this.environment,
    required this.rows,
    required this.start,
    required this.end,
  });

  final String environment;
  final List<List<String>> rows;
  final int start;
  final int end;
}

class _MatrixExpression extends StatelessWidget {
  const _MatrixExpression({required this.matrix, required this.style});

  final _ParsedMatrix matrix;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final bracketStyle = style.copyWith(
      fontSize: (style.fontSize ?? 14) * 1.7,
      height: 1,
      fontWeight: FontWeight.w500,
    );
    final cellStyle = style.copyWith(
      fontFamily: 'monospace',
      fontSize: (style.fontSize ?? 14) * 0.92,
      height: 1.15,
    );
    final bracketPair = switch (matrix.environment) {
      'pmatrix' => ('(', ')'),
      'bmatrix' => ('[', ']'),
      _ => ('', ''),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: WicaraColors.primarySoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (bracketPair.$1.isNotEmpty)
              Text(bracketPair.$1, style: bracketStyle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final row in matrix.rows)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < row.length; i++) ...[
                            if (i > 0) const SizedBox(width: 9),
                            Text(row[i], style: cellStyle),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (bracketPair.$2.isNotEmpty)
              Text(bracketPair.$2, style: bracketStyle),
          ],
        ),
      ),
    );
  }
}
