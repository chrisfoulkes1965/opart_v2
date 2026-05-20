import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/print/models/opart_recipe.dart';
import 'package:opart_v2/print/models/print_placement.dart';
import 'package:opart_v2/print/models/print_spec.dart';
import 'package:opart_v2/print/services/print_artwork_raster_service.dart';
import 'package:opart_v2/print/services/print_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrintArtworkRasterService', () {
    test('renders a flat square bitmap from recipe', () async {
      final recipe = OpArtRecipe.fromOpArt(
        OpArt(opArtType: OpArtType.Riley),
        seed: 4,
        animationValue: 1,
      );
      final service = PrintArtworkRasterService();

      final image = await service.artworkImage(recipe);

      expect(image.width, PrintArtworkRasterService.canonicalSidePx);
      expect(image.height, PrintArtworkRasterService.canonicalSidePx);

      service.clearCache();
    });
  });

  group('PrintExportService', () {
    test('renderRecipeToPng returns PNG bytes at requested dimensions',
        () async {
      final recipe = OpArtRecipe.fromOpArt(
        OpArt(opArtType: OpArtType.Riley),
        seed: 42,
        animationValue: 1,
      );
      final service = PrintExportService();
      const spec = PrintSpec(
        id: 'test',
        label: 'Test',
        widthPx: 600,
        heightPx: 800,
        dpi: 300,
        widthInches: 2,
        heightInches: 2.67,
      );

      final bytes = await service.renderRecipeToPng(
        recipe: recipe,
        spec: spec,
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50);
      expect(bytes[2], 0x4E);
      expect(bytes[3], 0x47);
    });

    test('renders wide mug print area from crop selection', () async {
      final recipe = OpArtRecipe.fromOpArt(
        OpArt(opArtType: OpArtType.Riley),
        seed: 1,
        animationValue: 1,
      );
      final service = PrintExportService();
      const spec = PrintSpec(
        id: '11oz',
        label: '11 oz',
        widthPx: 270,
        heightPx: 105,
        dpi: 300,
        widthInches: 9,
        heightInches: 3.5,
      );

      final bytes = await service.renderRecipeToPng(
        recipe: recipe,
        spec: spec,
      );

      expect(bytes, isNotEmpty);
    });

    test('placement size changes rendered PNG bytes', () async {
      final recipe = OpArtRecipe.fromOpArt(
        OpArt(opArtType: OpArtType.Tree),
        seed: 3,
        animationValue: 1,
      );
      final service = PrintExportService();
      const spec = PrintSpec(
        id: 'mug',
        label: 'Mug',
        widthPx: 400,
        heightPx: 160,
        dpi: 300,
        widthInches: 9,
        heightInches: 3.5,
      );

      final baseline = await service.renderRecipeToPng(
        recipe: recipe,
        spec: spec,
      );

      final cropped = await service.renderRecipeToPng(
        recipe: recipe,
        spec: spec,
        placement: const PrintPlacement(
          centerX: 0.25,
          centerY: 0.75,
          size: 0.5,
        ),
      );

      expect(baseline, isNotEmpty);
      expect(cropped, isNotEmpty);
      expect(baseline, isNot(equals(cropped)));
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

      final bytes = await PrintExportService().renderRecipeToPng(
        recipe: recipe,
        spec: spec,
      );

      expect(bytes.length, greaterThan(100));
    });
  });
}
