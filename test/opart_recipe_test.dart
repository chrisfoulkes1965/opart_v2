import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/print/models/opart_recipe.dart';

void main() {
  group('OpArtRecipe color parsing', () {
    test('parseColor handles ARGB integers', () {
      expect(
        OpArtRecipe.parseColor(0xFF37A7BC),
        const Color(0xFF37A7BC),
      );
    });

    test('parseColor handles legacy hex strings', () {
      expect(
        OpArtRecipe.parseColor('Color(0xFF37A7BC)'),
        const Color(0xFF37A7BC),
      );
    });

    test('parseColor handles component strings', () {
      final color = OpArtRecipe.parseColor(
        'Color(alpha: 1.0000, red: 0.2157, green: 0.6549, '
        'blue: 0.7373, colorSpace: ColorSpace.sRGB)',
      );

      expect(color, isNotNull);
      expect(color!.toARGB32(), const Color(0xFF37A7BC).toARGB32());
    });

    test('parseColorList handles ARGB integer lists', () {
      final colors = OpArtRecipe.parseColorList([
        0xFF37A7BC,
        0xFFB4B165,
      ]);

      expect(colors, [
        const Color(0xFF37A7BC),
        const Color(0xFFB4B165),
      ]);
    });

    test('parseColorList handles component string lists', () {
      final colors = OpArtRecipe.parseColorList(
        '[Color(alpha: 1.0000, red: 0.2157, green: 0.6549, '
        'blue: 0.7373, colorSpace: ColorSpace.sRGB), '
        'Color(alpha: 1.0000, red: 0.7059, green: 0.6941, '
        'blue: 0.3961, colorSpace: ColorSpace.sRGB)]',
      );

      expect(colors, [
        const Color(0xFF37A7BC),
        const Color(0xFFB4B165),
      ]);
    });

    test('parseColorList handles legacy stringified lists', () {
      final colors = OpArtRecipe.parseColorList(
        '[Color(0xFF37A7BC), Color(0xFFB4B165)]',
      );

      expect(colors, [
        const Color(0xFF37A7BC),
        const Color(0xFFB4B165),
      ]);
    });

    test('toOpArt restores saved palette colors from integer list', () {
      final source = OpArt(opArtType: OpArtType.Wallpaper);
      source.palette.colorList = [
        const Color(0xFF123456),
        const Color(0xFFABCDEF),
      ];
      source.palette.paletteName = 'Deck Chairs';

      final recipe = OpArtRecipe.fromOpArt(
        source,
        seed: 99,
        animationValue: 1,
      );
      recipe['colors'] = OpArtRecipe.colorListToJson(source.palette.colorList);

      final restored = OpArtRecipe.toOpArt(recipe);

      expect(restored.palette.colorList, source.palette.colorList);
    });
  });
}
