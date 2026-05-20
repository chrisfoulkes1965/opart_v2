import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_spec.dart';

/// Print dimensions at 300 DPI. Verify with [tool/printful_catalog_sync.dart].
class PrintSpecTemplates {
  PrintSpecTemplates._();

  static const int posterProductId = 268;
  static const int canvasProductId = 3;
  static const int framedPosterProductId = 2;
  static const int stickerProductId = 358;
  static const int tShirtProductId = 71;
  static const int hoodieProductId = 294;
  static const int mugProductId = 19;
  static const int notebookProductId = 474;
  static const int pillowProductId = 83;
  static const int toteProductId = 84;
  static const int coasterProductId = 611;
  static const int phoneCaseProductId = 601;
  static const int samsungPhoneCaseProductId = 686;
  static const int metalPrintProductId = 505;
  static const int tapestryProductId = 518;
  static const int holographicStickerProductId = 906;

  static List<PrintSpec> posterSizesFor(int productId) {
    return PosterPrintSpecs.defaults
        .map(
          (spec) => PrintSpec(
            id: spec.id,
            label: spec.label,
            widthPx: spec.widthPx,
            heightPx: spec.heightPx,
            dpi: spec.dpi,
            widthInches: spec.widthInches,
            heightInches: spec.heightInches,
            printfulProductId: productId,
          ),
        )
        .toList();
  }

  static const PrintSpec apparelFront = PrintSpec(
    id: 'front',
    label: 'Front print',
    widthPx: 3600,
    heightPx: 4800,
    dpi: 300,
    widthInches: 12,
    heightInches: 16,
    printfulProductId: tShirtProductId,
  );

  static PrintSpec apparelFrontFor(int productId) {
    return PrintSpec(
      id: apparelFront.id,
      label: apparelFront.label,
      widthPx: apparelFront.widthPx,
      heightPx: apparelFront.heightPx,
      dpi: apparelFront.dpi,
      widthInches: apparelFront.widthInches,
      heightInches: apparelFront.heightInches,
      printfulProductId: productId,
    );
  }

  static const List<PrintSpec> stickerSizes = [
    PrintSpec(
      id: '2x2',
      label: '2" × 2"',
      widthPx: 600,
      heightPx: 600,
      dpi: 300,
      widthInches: 2,
      heightInches: 2,
      printfulProductId: stickerProductId,
    ),
    PrintSpec(
      id: '3x3',
      label: '3" × 3"',
      widthPx: 900,
      heightPx: 900,
      dpi: 300,
      widthInches: 3,
      heightInches: 3,
      printfulProductId: stickerProductId,
    ),
    PrintSpec(
      id: '4x4',
      label: '4" × 4"',
      widthPx: 1200,
      heightPx: 1200,
      dpi: 300,
      widthInches: 4,
      heightInches: 4,
      printfulProductId: stickerProductId,
    ),
    PrintSpec(
      id: '5x5',
      label: '5" × 5"',
      widthPx: 1500,
      heightPx: 1500,
      dpi: 300,
      widthInches: 5,
      heightInches: 5,
      printfulProductId: stickerProductId,
    ),
    PrintSpec(
      id: '6x6',
      label: '6" × 6"',
      widthPx: 1800,
      heightPx: 1800,
      dpi: 300,
      widthInches: 6,
      heightInches: 6,
      printfulProductId: stickerProductId,
    ),
  ];

  static List<PrintSpec> stickerSizesFor(int productId) {
    return stickerSizes
        .map(
          (spec) => PrintSpec(
            id: spec.id,
            label: spec.label,
            widthPx: spec.widthPx,
            heightPx: spec.heightPx,
            dpi: spec.dpi,
            widthInches: spec.widthInches,
            heightInches: spec.heightInches,
            printfulProductId: productId,
          ),
        )
        .toList();
  }

  static PrintSpec mugForSize(String size, {int productId = mugProductId}) {
    switch (size) {
      case '15 oz':
        return PrintSpec(
          id: '15oz',
          label: '15 oz',
          widthPx: 2700,
          heightPx: 1140,
          dpi: 300,
          widthInches: 9,
          heightInches: 3.8,
          printfulProductId: productId,
        );
      case '20 oz':
        return PrintSpec(
          id: '20oz',
          label: '20 oz',
          widthPx: 2700,
          heightPx: 1140,
          dpi: 300,
          widthInches: 9,
          heightInches: 3.8,
          printfulProductId: productId,
        );
      default:
        return PrintSpec(
          id: '11oz',
          label: '11 oz',
          widthPx: 2700,
          heightPx: 1050,
          dpi: 300,
          widthInches: 9,
          heightInches: 3.5,
          printfulProductId: productId,
        );
    }
  }

  static const PrintSpec notebookCover = PrintSpec(
    id: 'cover',
    label: 'Cover',
    widthPx: 1950,
    heightPx: 1425,
    dpi: 300,
    widthInches: 6.5,
    heightInches: 4.75,
    printfulProductId: notebookProductId,
  );

  static const PrintSpec coaster = PrintSpec(
    id: '4x4',
    label: '4" × 4"',
    widthPx: 1200,
    heightPx: 1200,
    dpi: 300,
    widthInches: 4,
    heightInches: 4,
    printfulProductId: coasterProductId,
  );

  static const PrintSpec pillow18 = PrintSpec(
    id: '18x18',
    label: '18" × 18"',
    widthPx: 5400,
    heightPx: 5400,
    dpi: 300,
    widthInches: 18,
    heightInches: 18,
    printfulProductId: pillowProductId,
  );

  static const PrintSpec toteBag = PrintSpec(
    id: 'default',
    label: 'All-over print',
    widthPx: 4500,
    heightPx: 5100,
    dpi: 300,
    widthInches: 15,
    heightInches: 17,
    printfulProductId: toteProductId,
  );

  static const PrintSpec phoneCaseDefault = PrintSpec(
    id: 'default',
    label: 'Phone case',
    widthPx: 1290,
    heightPx: 2580,
    dpi: 300,
    widthInches: 4.3,
    heightInches: 8.6,
    printfulProductId: phoneCaseProductId,
  );

  static const PrintSpec tapestry = PrintSpec(
    id: '51x60',
    label: '51" × 60"',
    widthPx: 15300,
    heightPx: 18000,
    dpi: 300,
    widthInches: 51,
    heightInches: 60,
    printfulProductId: tapestryProductId,
  );

  static PrintSpec allOverPrintFor(int productId) {
    return switch (productId) {
      pillowProductId => pillow18,
      toteProductId => toteBag,
      tapestryProductId => tapestry,
      _ => toteBag.copyWithProductId(productId),
    };
  }

  static PrintSpec canonicalFor(int productId) {
    return switch (productId) {
      mugProductId => mugForSize('11 oz'),
      notebookProductId => notebookCover,
      coasterProductId => coaster,
      phoneCaseProductId => phoneCaseDefault,
      samsungPhoneCaseProductId =>
        phoneCaseDefault.copyWithProductId(samsungPhoneCaseProductId),
      _ when _usesStickerSizes(productId) => stickerSizesFor(productId).first,
      _ when _usesApparelFront(productId) => apparelFrontFor(productId),
      _ when _usesPosterSizes(productId) => posterSizesFor(productId).first,
      _ => allOverPrintFor(productId),
    };
  }

  static List<PrintSpec> sizeSpecsFor(int productId) {
    if (_usesPosterSizes(productId)) {
      return posterSizesFor(productId);
    }
    if (_usesStickerSizes(productId)) {
      return stickerSizesFor(productId);
    }
    return [canonicalFor(productId)];
  }

  static PrintSpec resolveForVariant({
    required int productId,
    required PrintVariant variant,
  }) {
    if (productId == mugProductId) {
      return mugForSize(variant.size, productId: productId).withPrintfulVariant(
        variantId: variant.id,
        productId: productId,
        sizeLabel: variant.size,
      );
    }

    if (_usesApparelFront(productId)) {
      return apparelFrontFor(productId).withPrintfulVariant(
        variantId: variant.id,
        productId: productId,
        sizeLabel: '${variant.color} · ${variant.size}',
      );
    }

    if (_usesPosterSizes(productId)) {
      return matchBySizeLabel(
        variant: variant,
        specs: posterSizesFor(productId),
      );
    }

    if (_usesStickerSizes(productId)) {
      return matchBySizeLabel(
        variant: variant,
        specs: stickerSizesFor(productId),
        squareOnly: true,
      );
    }

    if (productId == phoneCaseProductId ||
        productId == samsungPhoneCaseProductId) {
      return phoneCaseDefault.copyWithProductId(productId).withPrintfulVariant(
            variantId: variant.id,
            productId: productId,
            sizeLabel: variant.displayLabel,
          );
    }

    if (productId == notebookProductId) {
      return notebookCover.withPrintfulVariant(
        variantId: variant.id,
        productId: productId,
        sizeLabel: variant.displayLabel,
      );
    }

    if (productId == coasterProductId) {
      return coaster.withPrintfulVariant(
        variantId: variant.id,
        productId: productId,
        sizeLabel: variant.displayLabel,
      );
    }

    final base = allOverPrintFor(productId);
    return base.withPrintfulVariant(
      variantId: variant.id,
      productId: productId,
      sizeLabel: variant.displayLabel,
    );
  }

  static PrintSpec matchBySizeLabel({
    required PrintVariant variant,
    required List<PrintSpec> specs,
    bool squareOnly = false,
  }) {
    final sizeLabel = variant.size.isNotEmpty ? variant.size : variant.name;

    for (final spec in specs) {
      if (squareOnly) {
        final inch = spec.widthInches.toInt();
        if (sizeLabel.contains('$inch')) {
          return spec.withPrintfulVariant(
            variantId: variant.id,
            productId: variant.productId,
            sizeLabel: sizeLabel,
          );
        }
        continue;
      }

      if (sizeLabel.contains('${spec.widthInches.toInt()}') &&
          sizeLabel.contains('${spec.heightInches.toInt()}')) {
        return spec.withPrintfulVariant(
          variantId: variant.id,
          productId: variant.productId,
          sizeLabel: sizeLabel,
        );
      }
    }

    return specs.first.withPrintfulVariant(
      variantId: variant.id,
      productId: variant.productId,
      sizeLabel: sizeLabel,
    );
  }

  static bool _usesPosterSizes(int productId) {
    return productId == posterProductId ||
        productId == canvasProductId ||
        productId == framedPosterProductId ||
        productId == metalPrintProductId;
  }

  static bool _usesStickerSizes(int productId) {
    return productId == stickerProductId ||
        productId == holographicStickerProductId;
  }

  static bool _usesApparelFront(int productId) {
    return productId == tShirtProductId || productId == hoodieProductId;
  }
}

extension _PrintSpecProductId on PrintSpec {
  PrintSpec copyWithProductId(int productId) {
    return PrintSpec(
      id: id,
      label: label,
      widthPx: widthPx,
      heightPx: heightPx,
      dpi: dpi,
      widthInches: widthInches,
      heightInches: heightInches,
      printfulVariantId: printfulVariantId,
      printfulProductId: productId,
    );
  }
}
