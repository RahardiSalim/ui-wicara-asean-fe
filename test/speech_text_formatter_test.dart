import 'package:flutter_test/flutter_test.dart';
import 'package:wicara_mobile/src/core/accessibility/speech_text_formatter.dart';

void main() {
  group('SpeechTextFormatter.format', () {
    test('strips Markdown while preserving readable inner text', () {
      const raw =
          '# Heading\n**bold** *italic* __strong__ _emphasis_ '
          '[link](https://example.com) `code` ~~old~~';

      expect(
        SpeechTextFormatter.format(raw),
        'Heading bold italic strong emphasis link code old',
      );
    });

    test('converts supported LaTeX without exposing commands', () {
      const raw = r'$\frac{a}{b} + \sqrt{x} \times y \pm z$';

      final formatted = SpeechTextFormatter.format(raw);

      expect(
        formatted,
        'a per b + square root of x times y plus or minus z',
      );
      expect(formatted, isNot(contains(r'\')));
    });

    test('drops raw math delimiters and collapses whitespace', () {
      const raw = 'Use   \n  \$x + y\$  and  \\(n + 1\\).';

      expect(SpeechTextFormatter.format(raw), 'Use x + y and n + 1.');
    });
  });

  group('SpeechTextFormatter.chunk', () {
    test('chunks at sentence boundaries within the limit', () {
      final text = List.generate(
        12,
        (index) => 'Sentence $index has enough words to exercise chunking.',
      ).join(' ');

      final chunks = SpeechTextFormatter.chunk(text, maxChars: 120);

      expect(chunks.length, greaterThan(1));
      expect(chunks.every((chunk) => chunk.length <= 120), isTrue);
      expect(chunks.join(' '), text);
    });

    test('uses commas for a single sentence longer than the limit', () {
      const text =
          'This first clause has several words, this second clause also has '
          'several words, this final clause closes the unusually long sentence';

      final chunks = SpeechTextFormatter.chunk(text, maxChars: 55);

      expect(chunks.length, greaterThan(1));
      expect(chunks.every((chunk) => chunk.length <= 55), isTrue);
      expect(chunks.first, endsWith(','));
    });

    test('uses 800 characters as the default maximum', () {
      final text = List.generate(150, (index) => 'word$index').join(' ');

      final chunks = SpeechTextFormatter.chunk(text);

      expect(chunks.every((chunk) => chunk.length <= 800), isTrue);
      expect(chunks.join(' '), text);
    });
  });
}
