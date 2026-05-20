import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_product_definition.dart';
import 'package:opart_v2/print/models/print_spec.dart';
import 'package:opart_v2/print/models/print_spec_templates.dart';

sealed class PrintCatalogDisplayItem {
  const PrintCatalogDisplayItem();
}

class PrintCatalogProductItem extends PrintCatalogDisplayItem {
  const PrintCatalogProductItem(this.product);

  final PrintProduct product;
}

class PrintCatalogGroupItem extends PrintCatalogDisplayItem {
  const PrintCatalogGroupItem({
    required this.groupId,
    required this.title,
    required this.representativeProduct,
    required this.productIds,
    required this.variantCount,
  });

  final String groupId;
  final String title;
  final PrintProduct representativeProduct;
  final List<int> productIds;
  final int variantCount;
}

class PrintCatalog {
  PrintCatalog._();

  static final Map<int, PrintProductDefinition> definitions =
      PrintProductRegistry.byId;

  static List<int> get productIds => PrintProductRegistry.productIds;

  static const int posterProductId = PrintSpecTemplates.posterProductId;
  static const int tShirtProductId = PrintSpecTemplates.tShirtProductId;
  static const int mugProductId = PrintSpecTemplates.mugProductId;
  static const String phoneCaseGroupId = 'phone_cases';
  static const List<int> phoneCaseProductIds = [
    PrintSpecTemplates.phoneCaseProductId,
    PrintSpecTemplates.samsungPhoneCaseProductId,
  ];

  static const List<String> apparelPreferredColors = [
    'White',
    'Black',
    'Navy',
    'Red',
    'Dark Grey Heather',
    'Athletic Heather',
    'Asphalt',
    'Forest',
    'Maroon',
    'Royal',
  ];

  static const List<String> apparelSizeOrder = [
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

  static PrintProductDefinition? definitionFor(int productId) {
    return definitions[productId];
  }

  static PrintProductCategory categoryFor(int productId) {
    return definitionFor(productId)?.category ?? PrintProductCategory.wallArt;
  }

  static PrintProductBehavior behaviorFor(int productId) {
    return definitionFor(productId)?.behavior ??
        PrintProductBehavior.posterSizes;
  }

  static bool isDeviceCase(int productId) {
    return behaviorFor(productId) == PrintProductBehavior.deviceCase;
  }

  static bool isPhoneCaseGroupId(String? groupId) {
    return groupId == phoneCaseGroupId;
  }

  static bool isPhoneCaseProduct(int productId) {
    return phoneCaseProductIds.contains(productId);
  }

  static bool isApparelFront(int productId) {
    return behaviorFor(productId) == PrintProductBehavior.apparelFront;
  }

  static PrintFitMode fitModeFor(int productId) {
    return definitionFor(productId)?.fitMode ?? PrintFitMode.cover;
  }

  static String? mockupPlacementFor(int productId) {
    return definitionFor(productId)?.mockupPlacement;
  }

  static String displayTitleFor(PrintProduct product) {
    final override = definitionFor(product.id)?.displayTitle;
    if (override != null && override.isNotEmpty) {
      return override;
    }
    return _shortCatalogTitle(product.title);
  }

  static String _shortCatalogTitle(String title) {
    final pipeIndex = title.indexOf('|');
    if (pipeIndex == -1) {
      return title.trim();
    }
    return title.substring(0, pipeIndex).trim();
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
    return PrintSpecTemplates.canonicalFor(productId);
  }

  static String variantSubtitle(PrintProduct product) {
    return switch (behaviorFor(product.id)) {
      PrintProductBehavior.apparelFront => 'Colors & sizes',
      PrintProductBehavior.deviceCase => '${product.variantCount} models',
      PrintProductBehavior.singlePlacement => 'Cover print',
      PrintProductBehavior.allOverPrint => '${product.variantCount} options',
      PrintProductBehavior.mugWrap ||
      PrintProductBehavior.posterSizes ||
      PrintProductBehavior.squareSizes =>
        '${product.variantCount} sizes',
    };
  }

  static List<PrintProductCategory> orderedCategories() {
    return PrintProductCategory.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  static List<PrintProduct> productsForCategory(
    List<PrintProduct> products,
    PrintProductCategory category,
  ) {
    final idsInCategory =
        productIds.where((id) => categoryFor(id) == category).toSet();
    final byId = {for (final product in products) product.id: product};
    return productIds
        .where(idsInCategory.contains)
        .map((id) => byId[id])
        .whereType<PrintProduct>()
        .toList();
  }

  static List<PrintCatalogDisplayItem> displayItemsForCategory(
    List<PrintProduct> products,
    PrintProductCategory category,
  ) {
    final categoryProducts = productsForCategory(products, category);
    final items = <PrintCatalogDisplayItem>[];
    final seenGroups = <String>{};

    for (final product in categoryProducts) {
      final def = definitionFor(product.id);
      final groupId = def?.catalogGroupId;
      if (groupId != null && groupId.isNotEmpty) {
        if (seenGroups.contains(groupId)) {
          continue;
        }
        seenGroups.add(groupId);

        final groupProducts = categoryProducts.where((candidate) {
          return definitionFor(candidate.id)?.catalogGroupId == groupId;
        }).toList();
        final groupTitle = def?.catalogGroupTitle ?? displayTitleFor(product);
        final representative = groupProducts.first;
        final variantCount = groupProducts.fold<int>(
          0,
          (sum, groupProduct) => sum + groupProduct.variantCount,
        );

        items.add(
          PrintCatalogGroupItem(
            groupId: groupId,
            title: groupTitle,
            representativeProduct: representative,
            productIds: groupProducts.map((p) => p.id).toList(),
            variantCount: variantCount,
          ),
        );
        continue;
      }

      items.add(PrintCatalogProductItem(product));
    }

    return items;
  }

  static List<PrintVariant> filterVariants(
    int productId,
    List<PrintVariant> variants,
  ) {
    if (behaviorFor(productId) != PrintProductBehavior.apparelFront) {
      return variants.where((variant) => variant.inStock).toList();
    }

    final filtered = variants.where((variant) {
      if (!variant.inStock) {
        return false;
      }
      return apparelPreferredColors.contains(variant.color);
    }).toList();

    filtered.sort((a, b) {
      final colorCompare = apparelPreferredColors
          .indexOf(a.color)
          .compareTo(apparelPreferredColors.indexOf(b.color));
      if (colorCompare != 0) {
        return colorCompare;
      }

      final sizeCompare = apparelSizeOrder
          .indexOf(a.size)
          .compareTo(apparelSizeOrder.indexOf(b.size));
      if (sizeCompare != 0) {
        return sizeCompare;
      }

      return a.name.compareTo(b.name);
    });

    return filtered;
  }

  static List<PrintVariant> searchVariants(
    List<PrintVariant> variants,
    String query,
  ) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return variants;
    }

    return variants.where((variant) {
      return variant.name.toLowerCase().contains(trimmed) ||
          variant.size.toLowerCase().contains(trimmed) ||
          variant.color.toLowerCase().contains(trimmed) ||
          variant.displayLabel.toLowerCase().contains(trimmed);
    }).toList();
  }

  static PrintSpec resolveSpec({
    required PrintProduct? product,
    required PrintVariant variant,
  }) {
    return PrintSpecTemplates.resolveForVariant(
      productId: variant.productId,
      variant: variant,
    );
  }
}
