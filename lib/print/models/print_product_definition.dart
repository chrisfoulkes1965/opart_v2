import 'package:opart_v2/print/models/print_spec.dart';

enum PrintProductCategory {
  wallArt,
  apparel,
  home,
  accessories,
  gifts,
}

extension PrintProductCategoryX on PrintProductCategory {
  String get label => switch (this) {
        PrintProductCategory.wallArt => 'Wall art',
        PrintProductCategory.apparel => 'Apparel',
        PrintProductCategory.home => 'Home',
        PrintProductCategory.accessories => 'Accessories',
        PrintProductCategory.gifts => 'Gifts',
      };

  int get sortOrder => switch (this) {
        PrintProductCategory.wallArt => 0,
        PrintProductCategory.apparel => 1,
        PrintProductCategory.home => 2,
        PrintProductCategory.accessories => 3,
        PrintProductCategory.gifts => 4,
      };
}

enum PrintProductBehavior {
  posterSizes,
  apparelFront,
  mugWrap,
  squareSizes,
  allOverPrint,
  singlePlacement,
  deviceCase,
}

class PrintProductDefinition {
  const PrintProductDefinition({
    required this.productId,
    required this.category,
    required this.behavior,
    this.displayTitle,
    this.catalogGroupId,
    this.catalogGroupTitle,
    this.fitMode = PrintFitMode.cover,
    this.mockupPlacement,
    this.displayOrder = 0,
  });

  final int productId;
  final PrintProductCategory category;
  final PrintProductBehavior behavior;
  final String? displayTitle;
  final String? catalogGroupId;
  final String? catalogGroupTitle;
  final PrintFitMode fitMode;
  final String? mockupPlacement;
  final int displayOrder;
}

/// Keep in sync with [supabase/functions/_shared/catalog.ts].
class PrintProductRegistry {
  PrintProductRegistry._();

  static const List<PrintProductDefinition> all = [
    PrintProductDefinition(
      productId: 268,
      category: PrintProductCategory.wallArt,
      behavior: PrintProductBehavior.posterSizes,
      displayOrder: 0,
    ),
    PrintProductDefinition(
      productId: 3,
      category: PrintProductCategory.wallArt,
      behavior: PrintProductBehavior.posterSizes,
      displayOrder: 1,
    ),
    PrintProductDefinition(
      productId: 2,
      category: PrintProductCategory.wallArt,
      behavior: PrintProductBehavior.posterSizes,
      displayOrder: 2,
    ),
    PrintProductDefinition(
      productId: 358,
      category: PrintProductCategory.wallArt,
      behavior: PrintProductBehavior.squareSizes,
      displayOrder: 3,
    ),
    PrintProductDefinition(
      productId: 71,
      category: PrintProductCategory.apparel,
      behavior: PrintProductBehavior.apparelFront,
      displayTitle: 'T-shirt',
      mockupPlacement: 'front',
      displayOrder: 0,
    ),
    PrintProductDefinition(
      productId: 294,
      category: PrintProductCategory.apparel,
      behavior: PrintProductBehavior.apparelFront,
      displayTitle: 'Hoodie',
      mockupPlacement: 'front',
      displayOrder: 1,
    ),
    PrintProductDefinition(
      productId: 19,
      category: PrintProductCategory.home,
      behavior: PrintProductBehavior.mugWrap,
      displayOrder: 0,
    ),
    PrintProductDefinition(
      productId: 474,
      category: PrintProductCategory.home,
      behavior: PrintProductBehavior.singlePlacement,
      displayOrder: 1,
    ),
    PrintProductDefinition(
      productId: 83,
      category: PrintProductCategory.home,
      behavior: PrintProductBehavior.allOverPrint,
      displayOrder: 2,
    ),
    PrintProductDefinition(
      productId: 84,
      category: PrintProductCategory.home,
      behavior: PrintProductBehavior.allOverPrint,
      displayOrder: 3,
    ),
    PrintProductDefinition(
      productId: 611,
      category: PrintProductCategory.home,
      behavior: PrintProductBehavior.singlePlacement,
      displayOrder: 4,
    ),
    PrintProductDefinition(
      productId: 601,
      category: PrintProductCategory.accessories,
      behavior: PrintProductBehavior.deviceCase,
      catalogGroupId: 'phone_cases',
      catalogGroupTitle: 'Phone cases',
      displayOrder: 0,
    ),
    PrintProductDefinition(
      productId: 686,
      category: PrintProductCategory.accessories,
      behavior: PrintProductBehavior.deviceCase,
      catalogGroupId: 'phone_cases',
      catalogGroupTitle: 'Phone cases',
      displayOrder: 1,
    ),
    PrintProductDefinition(
      productId: 505,
      category: PrintProductCategory.gifts,
      behavior: PrintProductBehavior.posterSizes,
      displayOrder: 0,
    ),
    PrintProductDefinition(
      productId: 518,
      category: PrintProductCategory.gifts,
      behavior: PrintProductBehavior.allOverPrint,
      displayOrder: 1,
    ),
    PrintProductDefinition(
      productId: 906,
      category: PrintProductCategory.gifts,
      behavior: PrintProductBehavior.squareSizes,
      displayOrder: 2,
    ),
  ];

  static Map<int, PrintProductDefinition> get byId {
    return {for (final def in all) def.productId: def};
  }

  static List<int> get productIds {
    final sorted = List<PrintProductDefinition>.from(all)
      ..sort((a, b) {
        final categoryCompare =
            a.category.sortOrder.compareTo(b.category.sortOrder);
        if (categoryCompare != 0) {
          return categoryCompare;
        }
        return a.displayOrder.compareTo(b.displayOrder);
      });
    return sorted.map((def) => def.productId).toList();
  }
}
