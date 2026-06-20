final class SpeechTextFormatter {
  const SpeechTextFormatter._();

  static String format(String raw) {
    var text = raw
        .replaceAllMapped(
          RegExp(r'!\[([^\]]*)\]\([^)]*\)'),
          (match) => match.group(1) ?? '',
        )
        .replaceAllMapped(
          RegExp(r'\[([^\]]+)\]\([^)]*\)'),
          (match) => match.group(1) ?? '',
        )
        .replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'```(?:[A-Za-z0-9_+-]+)?'), '')
        .replaceAll('`', '')
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('~~', '')
        .replaceAll('*', '')
        .replaceAll('_', '');

    text = _replaceRepeatedly(
      text,
      RegExp(r'\\frac\s*\{([^{}]*)\}\s*\{([^{}]*)\}'),
      (match) => '${match.group(1)} per ${match.group(2)}',
    );
    text = _replaceRepeatedly(
      text,
      RegExp(r'\\sqrt\s*\{([^{}]*)\}'),
      (match) => 'square root of ${match.group(1)}',
    );
    text = text
        .replaceAllMapped(
          RegExp(r'\^\{([^{}]*)\}'),
          (match) => ' to the power of ${match.group(1)}',
        )
        .replaceAll(RegExp(r'\\times\b'), ' times ')
        .replaceAll(RegExp(r'\\div\b'), ' divided by ')
        .replaceAll(RegExp(r'\\pm\b'), ' plus or minus ')
        .replaceAll(r'\(', '')
        .replaceAll(r'\)', '')
        .replaceAll(r'\[', '')
        .replaceAll(r'\]', '')
        .replaceAll(r'$$', '')
        .replaceAll(r'$', '')
        .replaceAllMapped(
          RegExp(r'\\([A-Za-z]+)'),
          (match) => ' ${match.group(1)} ',
        )
        .replaceAll(RegExp(r'\\'), ' ')
        .replaceAll(RegExp(r'[{}]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return text;
  }

  static List<String> chunk(String text, {int maxChars = 800}) {
    if (maxChars <= 0) {
      throw ArgumentError.value(maxChars, 'maxChars', 'Must be positive.');
    }
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return const [];
    }

    final sentences = RegExp(
      r'.+?(?:[.!?](?=\s|$)|$)',
      dotAll: true,
    ).allMatches(normalized).map((match) => match.group(0)!.trim()).where(
      (sentence) => sentence.isNotEmpty,
    );

    final chunks = <String>[];
    var current = '';
    for (final sentence in sentences) {
      final parts = sentence.length <= maxChars
          ? <String>[sentence]
          : _splitLongSentence(sentence, maxChars);
      for (final part in parts) {
        final candidate = current.isEmpty ? part : '$current $part';
        if (current.isNotEmpty && candidate.length > maxChars) {
          chunks.add(current);
          current = part;
        } else {
          current = candidate;
        }
      }
    }
    if (current.isNotEmpty) {
      chunks.add(current);
    }
    return chunks;
  }

  static String _replaceRepeatedly(
    String input,
    RegExp pattern,
    String Function(Match match) replacement,
  ) {
    var output = input;
    while (pattern.hasMatch(output)) {
      output = output.replaceAllMapped(pattern, replacement);
    }
    return output;
  }

  static List<String> _splitLongSentence(String sentence, int maxChars) {
    final parts = <String>[];
    var remaining = sentence.trim();
    while (remaining.length > maxChars) {
      final window = remaining.substring(0, maxChars + 1);
      var splitAt = _lastPreferredBreak(window);
      final includePunctuation = splitAt > 0;
      if (splitAt <= 0) {
        splitAt = window.lastIndexOf(RegExp(r'\s'));
      }
      if (splitAt <= 0) {
        final nextSpace = remaining.indexOf(RegExp(r'\s'), maxChars);
        if (nextSpace < 0) {
          parts.add(remaining);
          return parts;
        }
        splitAt = nextSpace;
      }
      final end = includePunctuation ? splitAt + 1 : splitAt;
      final part = remaining.substring(0, end).trim();
      if (part.isNotEmpty) {
        parts.add(part);
      }
      remaining = remaining.substring(end).trimLeft();
    }
    if (remaining.isNotEmpty) {
      parts.add(remaining);
    }
    return parts;
  }

  static int _lastPreferredBreak(String text) {
    final comma = text.lastIndexOf(',');
    final emDash = text.lastIndexOf('—');
    return comma > emDash ? comma : emDash;
  }
}
