import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/palette_contrast.dart';

void main() {
  group('contrastRatio', () {
    test('returns 1 for identical colors', () {
      expect(contrastRatio(Colors.white, Colors.white), closeTo(1.0, 0.01));
    });

    test('returns high ratio for black and white', () {
      expect(contrastRatio(Colors.black, Colors.white), closeTo(21.0, 0.1));
    });
  });

  group('alphaBlended', () {
    test('returns foreground at full opacity', () {
      expect(
        alphaBlended(Colors.red, Colors.blue, 1.0),
        const Color(0xFFF44336),
      );
    });

    test('returns background at zero opacity', () {
      expect(
        alphaBlended(Colors.red, Colors.blue, 0.0),
        Colors.blue,
      );
    });
  });

  group('ensureContrastAgainstBackground', () {
    test('returns unchanged color when contrast is already sufficient', () {
      const color = Color(0xFFFF0000);
      const background = Color(0xFF000000);

      expect(
        ensureContrastAgainstBackground(color: color, background: background),
        color,
      );
    });

    test('adjusts near-identical color to improve contrast', () {
      const background = Color(0xFF4488AA);
      const color = Color(0xFF4589AB);

      final adjusted = ensureContrastAgainstBackground(
        color: color,
        background: background,
      );

      expect(
        contrastRatio(adjusted, background),
        greaterThanOrEqualTo(kMinPaletteContrastRatio),
      );
      expect(adjusted, isNot(equals(color)));
    });

    test('pushes color darker on light background', () {
      const background = Colors.white;
      const color = Color(0xFFEEEEEE);

      final adjusted = ensureContrastAgainstBackground(
        color: color,
        background: background,
      );

      expect(adjusted.computeLuminance(), lessThan(color.computeLuminance()));
      expect(
        contrastRatio(
          alphaBlended(adjusted, background, 1.0),
          background,
        ),
        greaterThanOrEqualTo(kMinPaletteContrastRatio),
      );
    });

    test('pushes color lighter on dark background', () {
      const background = Colors.black;
      const color = Color(0xFF111111);

      final adjusted = ensureContrastAgainstBackground(
        color: color,
        background: background,
      );

      expect(
          adjusted.computeLuminance(), greaterThan(color.computeLuminance()));
      expect(
        contrastRatio(
          alphaBlended(adjusted, background, 1.0),
          background,
        ),
        greaterThanOrEqualTo(kMinPaletteContrastRatio),
      );
    });

    test('requires more adjustment at lower opacity', () {
      const background = Color(0xFF808080);
      const color = Color(0xFF858585);

      final atFullOpacity = ensureContrastAgainstBackground(
        color: color,
        background: background,
        alpha: 1.0,
      );
      final atLowOpacity = ensureContrastAgainstBackground(
        color: color,
        background: background,
        alpha: 0.3,
      );

      final fullOpacityDelta =
          (atFullOpacity.computeLuminance() - color.computeLuminance()).abs();
      final lowOpacityDelta =
          (atLowOpacity.computeLuminance() - color.computeLuminance()).abs();
      expect(lowOpacityDelta, greaterThanOrEqualTo(fullOpacityDelta));
      expect(
        contrastRatio(
          alphaBlended(atLowOpacity, background, 0.3),
          background,
        ),
        greaterThanOrEqualTo(
            effectiveMinContrastRatio(kMinPaletteContrastRatio, 0.3)),
      );
    });
  });
}
