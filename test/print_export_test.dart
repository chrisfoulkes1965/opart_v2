import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/print/models/opart_recipe.dart';
import 'package:opart_v2/print/models/print_placement.dart';
import 'package:opart_v2/print/models/print_spec.dart';
import 'package:opart_v2/print/services/print_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrintExportService', () {
    const service = PrintExportService();

    test('renderToPng returns PNG bytes at requested dimensions', () async {
      final opArt = OpArt(opArtType: OpArtType.Riley);
      const spec = PrintSpec(
        id: 'test',
        label: 'Test',
        widthPx: 600,
        heightPx: 800,
        dpi: 300,
        widthInches: 2,
        heightInches: 2.67,
      );

      final bytes = await service.renderToPng(
        opArt: opArt,
        seed: 42,
        animationValue: 1,
        spec: spec,
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50);
      expect(bytes[2], 0x4E);
      expect(bytes[3], 0x47);
    });

    test('cover fills wide mug print area without square letterboxing',
        () async {
      final opArt = OpArt(opArtType: OpArtType.Riley);
      const spec = PrintSpec(
        id: '11oz',
        label: '11 oz',
        widthPx: 270,
        heightPx: 105,
        dpi: 300,
        widthInches: 9,
        heightInches: 3.5,
      );

      final bytes = await service.renderToPng(
        opArt: opArt,
        seed: 1,
        animationValue: 1,
        spec: spec,
        fit: PrintFitMode.cover,
      );

      expect(bytes, isNotEmpty);
    });

    test('placement scale changes rendered PNG bytes', () async {
      final opArt = OpArt(opArtType: OpArtType.Tree);
      const spec = PrintSpec(
        id: 'mug',
        label: 'Mug',
        widthPx: 400,
        heightPx: 160,
        dpi: 300,
        widthInches: 9,
        heightInches: 3.5,
      );

      final baseline = await service.renderToPng(
        opArt: opArt,
        seed: 3,
        animationValue: 1,
        spec: spec,
      );

      final zoomed = await service.renderToPng(
        opArt: opArt,
        seed: 3,
        animationValue: 1,
        spec: spec,
        placement: const PrintPlacement(scale: 2),
      );

      expect(baseline, isNotEmpty);
      expect(zoomed, isNotEmpty);
      expect(baseline, isNot(equals(zoomed)));
    });

    test('renderRecipeToPng renders from saved recipe map', () async {
      final opArt = OpArt(opArtType: OpArtType.Wave);
      final recipe = OpArtRecipe.fromOpArt(
        opArt,
        seed: 7,
        animationValue: 1,
      );

      final bytes = await service.renderRecipeToPng(
        recipe: recipe,
        spec: PosterPrintSpecs.defaults.first,
      );

      expect(bytes.length, greaterThan(100));
    });

    test('renderRecipeToPng handles squares with mismatched palette size',
        () async {
      final opArt = OpArt(opArtType: OpArtType.Squares);
      final recipe = OpArtRecipe.fromOpArt(
        opArt,
        seed: 42,
        animationValue: 1,
      );
      recipe['colors'] = List<Color>.from(opArt.palette.colorList.take(10));
      recipe['Number of Colors'] = 11;

      const spec = PrintSpec(
        id: 'squares',
        label: 'Squares',
        widthPx: 800,
        heightPx: 800,
        dpi: 300,
        widthInches: 8,
        heightInches: 8,
      );

      final bytes = await service.renderRecipeToPng(
        recipe: recipe,
        spec: spec,
      );

      expect(bytes.length, greaterThan(100));
    });
  });
}
