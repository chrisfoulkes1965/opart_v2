/// How square op art is scaled into a (possibly non-square) print area.
enum PrintFitMode {
  /// Fills the print area; edges may be cropped.
  cover,

  /// Fits inside the print area; may letterbox.
  contain,
}

class PrintSpec {
  const PrintSpec({
    required this.id,
    required this.label,
    required this.widthPx,
    required this.heightPx,
    required this.dpi,
    required this.widthInches,
    required this.heightInches,
    this.printfulVariantId,
    this.printfulProductId = PosterPrintSpecs.mvpProductId,
  });

  final String id;
  final String label;
  final int widthPx;
  final int heightPx;
  final int dpi;
  final double widthInches;
  final double heightInches;
  final int? printfulVariantId;
  final int printfulProductId;

  double get aspectRatio => widthPx / heightPx;

  /// Scales dimensions for fast on-device previews (max edge [maxDimensionPx]).
  PrintSpec scaledToMaxDimension(int maxDimensionPx) {
    final maxEdge = widthPx > heightPx ? widthPx : heightPx;
    if (maxEdge <= maxDimensionPx) {
      return this;
    }
    final scale = maxDimensionPx / maxEdge;
    return PrintSpec(
      id: id,
      label: label,
      widthPx: (widthPx * scale).round(),
      heightPx: (heightPx * scale).round(),
      dpi: dpi,
      widthInches: widthInches,
      heightInches: heightInches,
      printfulVariantId: printfulVariantId,
      printfulProductId: printfulProductId,
    );
  }

  PrintSpec withPrintfulVariant({
    required int variantId,
    required int productId,
    String? sizeLabel,
  }) {
    return PrintSpec(
      id: id,
      label: sizeLabel?.isNotEmpty == true ? sizeLabel! : label,
      widthPx: widthPx,
      heightPx: heightPx,
      dpi: dpi,
      widthInches: widthInches,
      heightInches: heightInches,
      printfulVariantId: variantId,
      printfulProductId: productId,
    );
  }

  /// Applies Printful print-area dimensions (crop + export match fulfillment).
  PrintSpec withPrintArea({
    required int widthPx,
    required int heightPx,
    required int dpi,
  }) {
    return PrintSpec(
      id: id,
      label: label,
      widthPx: widthPx,
      heightPx: heightPx,
      dpi: dpi,
      widthInches: widthPx / dpi,
      heightInches: heightPx / dpi,
      printfulVariantId: printfulVariantId,
      printfulProductId: printfulProductId,
    );
  }
}

class PosterPrintSpecs {
  static const int mvpProductId = 268;

  static const List<PrintSpec> defaults = [
    PrintSpec(
      id: '12x16',
      label: '12" × 16"',
      widthPx: 3600,
      heightPx: 4800,
      dpi: 300,
      widthInches: 12,
      heightInches: 16,
    ),
    PrintSpec(
      id: '18x24',
      label: '18" × 24"',
      widthPx: 5400,
      heightPx: 7200,
      dpi: 300,
      widthInches: 18,
      heightInches: 24,
    ),
    PrintSpec(
      id: '24x36',
      label: '24" × 36"',
      widthPx: 7200,
      heightPx: 10800,
      dpi: 300,
      widthInches: 24,
      heightInches: 36,
    ),
  ];

  static PrintSpec? byId(String id) {
    for (final spec in defaults) {
      if (spec.id == id) {
        return spec;
      }
    }
    return null;
  }
}
