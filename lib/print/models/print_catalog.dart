import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_spec.dart';

enum PrintProductKind {
  poster,
  apparel,
  mug,
}

class PrintCatalog {
  static const int posterProductId = 268;
  static const int tShirtProductId = 71;
  static const int mugProductId = 19;

  static const List<int> productIds = [
    posterProductId,
    tShirtProductId,
    mugProductId,
  ];

  static const List<String> _apparelPreferredColors = ['White', 'Black'];
  static const List<String> _apparelSizeOrder = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    '2XL',
    '3XL',
    '4XL',
    '5XL',
  ];

  static PrintProductKind kindFor(int productId) {
    switch (productId) {
      case tShirtProductId:
        return PrintProductKind.apparel;
      case mugProductId:
        return PrintProductKind.mug;
      default:
        return PrintProductKind.poster;
    }
  }

  static PrintFitMode fitModeFor(int productId) {
    return PrintFitMode.cover;
  }

  static const int previewMaxDimensionPx = 640;

  static const PrintSpec squareArtworkPreviewSpec = PrintSpec(
    id: 'square',
    label: 'Square',
    widthPx: 640,
    heightPx: 640,
    dpi: 300,
    widthInches: 4,
    heightInches: 4,
  );

  static bool isRecipeValid(Map<String, dynamic> recipe) {
    return recipe.containsKey('type');
  }

  static PrintSpec canonicalPreviewSpec(int productId) {
    switch (kindFor(productId)) {
      case PrintProductKind.mug:
        return _mugSpecForSize('11 oz');
      case PrintProductKind.apparel:
        return _tShirtSpec;
      case PrintProductKind.poster:
        return PosterPrintSpecs.defaults.first;
    }
  }

  static String variantSubtitle(PrintProduct product) {
    switch (kindFor(product.id)) {
      case PrintProductKind.apparel:
        return 'Colors & sizes';
      case PrintProductKind.mug:
        return '${product.variantCount} sizes';
      case PrintProductKind.poster:
        return '${product.variantCount} sizes';
    }
  }

  static List<PrintVariant> filterVariants(
    int productId,
    List<PrintVariant> variants,
  ) {
    if (kindFor(productId) != PrintProductKind.apparel) {
      return variants.where((variant) => variant.inStock).toList();
    }

    final filtered = variants.where((variant) {
      if (!variant.inStock) {
        return false;
      }
      return _apparelPreferredColors.contains(variant.color);
    }).toList();

    filtered.sort((a, b) {
      final colorCompare = _apparelPreferredColors
          .indexOf(a.color)
          .compareTo(_apparelPreferredColors.indexOf(b.color));
      if (colorCompare != 0) {
        return colorCompare;
      }

      final sizeCompare = _apparelSizeOrder
          .indexOf(a.size)
          .compareTo(_apparelSizeOrder.indexOf(b.size));
      if (sizeCompare != 0) {
        return sizeCompare;
      }

      return a.name.compareTo(b.name);
    });

    return filtered;
  }

  static PrintSpec resolveSpec({
    required PrintProduct? product,
    required PrintVariant variant,
  }) {
    switch (kindFor(variant.productId)) {
      case PrintProductKind.mug:
        return _mugSpecForSize(variant.size).withPrintfulVariant(
          variantId: variant.id,
          productId: variant.productId,
          sizeLabel: variant.size,
        );
      case PrintProductKind.apparel:
        return _tShirtSpec.withPrintfulVariant(
          variantId: variant.id,
          productId: variant.productId,
          sizeLabel: '${variant.color} · ${variant.size}',
        );
      case PrintProductKind.poster:
        return _resolvePosterSpec(variant);
    }
  }

  static PrintSpec _resolvePosterSpec(PrintVariant variant) {
    for (final spec in PosterPrintSpecs.defaults) {
      if (variant.size.contains('${spec.widthInches.toInt()}') &&
          variant.size.contains('${spec.heightInches.toInt()}')) {
        return spec.withPrintfulVariant(
          variantId: variant.id,
          productId: variant.productId,
          sizeLabel: variant.size,
        );
      }
    }

    return PosterPrintSpecs.defaults.first.withPrintfulVariant(
      variantId: variant.id,
      productId: variant.productId,
      sizeLabel: variant.size,
    );
  }

  static PrintSpec _mugSpecForSize(String size) {
    switch (size) {
      case '15 oz':
        return const PrintSpec(
          id: '15oz',
          label: '15 oz',
          widthPx: 2700,
          heightPx: 1140,
          dpi: 300,
          widthInches: 9,
          heightInches: 3.8,
          printfulProductId: mugProductId,
        );
      case '20 oz':
        return const PrintSpec(
          id: '20oz',
          label: '20 oz',
          widthPx: 2700,
          heightPx: 1140,
          dpi: 300,
          widthInches: 9,
          heightInches: 3.8,
          printfulProductId: mugProductId,
        );
      default:
        return const PrintSpec(
          id: '11oz',
          label: '11 oz',
          widthPx: 2700,
          heightPx: 1050,
          dpi: 300,
          widthInches: 9,
          heightInches: 3.5,
          printfulProductId: mugProductId,
        );
    }
  }

  static const PrintSpec _tShirtSpec = PrintSpec(
    id: 'front',
    label: 'Front print',
    widthPx: 3600,
    heightPx: 4800,
    dpi: 300,
    widthInches: 12,
    heightInches: 16,
    printfulProductId: tShirtProductId,
  );
}
