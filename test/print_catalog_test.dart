import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/print/models/print_catalog.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_product_definition.dart';
import 'package:opart_v2/print/models/print_spec_templates.dart';

void main() {
  group('PrintCatalog registry', () {
    test('has 16 unique product IDs', () {
      expect(PrintCatalog.productIds, hasLength(16));
      expect(PrintCatalog.productIds.toSet(), hasLength(16));
    });

    test('product IDs match PrintProductRegistry', () {
      expect(
        PrintCatalog.productIds,
        PrintProductRegistry.productIds,
      );
    });

    test('every registered product resolves canonicalPreviewSpec', () {
      for (final id in PrintCatalog.productIds) {
        final spec = PrintCatalog.canonicalPreviewSpec(id);
        expect(spec.widthPx, greaterThan(0));
        expect(spec.heightPx, greaterThan(0));
      }
    });

    test('resolveSpec returns poster dimensions for 18x24', () {
      const variant = PrintVariant(
        id: 1,
        productId: PrintSpecTemplates.posterProductId,
        name: 'Enhanced Matte Paper Poster (18×24)',
        size: '18×24',
        color: '',
        price: '19.99',
        inStock: true,
        imageUrl: '',
      );

      final spec = PrintCatalog.resolveSpec(product: null, variant: variant);

      expect(spec.widthPx, 5400);
      expect(spec.heightPx, 7200);
    });

    test('resolveSpec returns mug wrap for 11 oz', () {
      const variant = PrintVariant(
        id: 2,
        productId: PrintSpecTemplates.mugProductId,
        name: '11 oz',
        size: '11 oz',
        color: 'White',
        price: '9.99',
        inStock: true,
        imageUrl: '',
      );

      final spec = PrintCatalog.resolveSpec(product: null, variant: variant);

      expect(spec.widthPx, 2700);
      expect(spec.heightPx, 1050);
    });

    test('resolveSpec returns square sticker for 3 inch size', () {
      const variant = PrintVariant(
        id: 3,
        productId: PrintSpecTemplates.stickerProductId,
        name: '3″×3″',
        size: '3″×3″',
        color: '',
        price: '2.50',
        inStock: true,
        imageUrl: '',
      );

      final spec = PrintCatalog.resolveSpec(product: null, variant: variant);

      expect(spec.widthPx, 900);
      expect(spec.heightPx, 900);
    });

    test('resolveSpec returns apparel front for tee', () {
      const variant = PrintVariant(
        id: 4,
        productId: PrintSpecTemplates.tShirtProductId,
        name: 'White / M',
        size: 'M',
        color: 'White',
        price: '14.99',
        inStock: true,
        imageUrl: '',
      );

      final spec = PrintCatalog.resolveSpec(product: null, variant: variant);

      expect(spec.widthPx, 3600);
      expect(spec.heightPx, 4800);
      expect(spec.label, 'White · M');
    });

    test('filterVariants keeps allowlisted in-stock apparel colors', () {
      final variants = [
        const PrintVariant(
          id: 1,
          productId: PrintSpecTemplates.tShirtProductId,
          name: 'White / M',
          size: 'M',
          color: 'White',
          price: '14.99',
          inStock: true,
          imageUrl: '',
        ),
        const PrintVariant(
          id: 2,
          productId: PrintSpecTemplates.tShirtProductId,
          name: 'Red / M',
          size: 'M',
          color: 'Red',
          price: '14.99',
          inStock: true,
          imageUrl: '',
        ),
        const PrintVariant(
          id: 3,
          productId: PrintSpecTemplates.tShirtProductId,
          name: 'Black / S',
          size: 'S',
          color: 'Black',
          price: '14.99',
          inStock: true,
          imageUrl: '',
        ),
        const PrintVariant(
          id: 4,
          productId: PrintSpecTemplates.tShirtProductId,
          name: 'Pink / M',
          size: 'M',
          color: 'Pink',
          price: '14.99',
          inStock: true,
          imageUrl: '',
        ),
        const PrintVariant(
          id: 5,
          productId: PrintSpecTemplates.tShirtProductId,
          name: 'Navy / L',
          size: 'L',
          color: 'Navy',
          price: '14.99',
          inStock: false,
          imageUrl: '',
        ),
      ];

      final filtered = PrintCatalog.filterVariants(
        PrintSpecTemplates.tShirtProductId,
        variants,
      );

      expect(filtered, hasLength(3));
      expect(filtered.map((v) => v.color), ['White', 'Black', 'Red']);
    });

    test('isApparelFront identifies tee and hoodie', () {
      expect(PrintCatalog.isApparelFront(71), isTrue);
      expect(PrintCatalog.isApparelFront(294), isTrue);
      expect(PrintCatalog.isApparelFront(19), isFalse);
    });

    test('searchVariants filters phone case models', () {
      final variants = [
        const PrintVariant(
          id: 1,
          productId: PrintSpecTemplates.phoneCaseProductId,
          name: 'Tough Case for iPhone 16 Pro',
          size: 'iPhone 16 Pro',
          color: 'Glossy',
          price: '17.50',
          inStock: true,
          imageUrl: '',
        ),
        const PrintVariant(
          id: 2,
          productId: PrintSpecTemplates.phoneCaseProductId,
          name: 'Tough Case for iPhone 14',
          size: 'iPhone 14',
          color: 'Glossy',
          price: '17.50',
          inStock: true,
          imageUrl: '',
        ),
      ];

      final results = PrintCatalog.searchVariants(variants, 'iPhone 16');

      expect(results, hasLength(1));
      expect(results.first.name, contains('16 Pro'));
    });

    test('searchVariants returns all when query is empty', () {
      final variants = [
        const PrintVariant(
          id: 1,
          productId: PrintSpecTemplates.phoneCaseProductId,
          name: 'Model A',
          size: 'A',
          color: '',
          price: '1',
          inStock: true,
          imageUrl: '',
        ),
      ];

      expect(PrintCatalog.searchVariants(variants, ''), variants);
    });

    test('productsForCategory preserves catalog order', () {
      const products = [
        PrintProduct(
          id: 358,
          title: 'Stickers',
          typeName: 'Sticker',
          imageUrl: '',
          variantCount: 5,
        ),
        PrintProduct(
          id: 268,
          title: 'Poster',
          typeName: 'Poster',
          imageUrl: '',
          variantCount: 3,
        ),
      ];

      final wallArt = PrintCatalog.productsForCategory(
        products,
        PrintProductCategory.wallArt,
      );

      expect(wallArt.map((p) => p.id), [268, 358]);
    });

    test('resolveSpec returns square coaster dimensions', () {
      const variant = PrintVariant(
        id: 20,
        productId: PrintSpecTemplates.coasterProductId,
        name: 'Cork-Back Coaster',
        size: '4″×4″',
        color: '',
        price: '5.44',
        inStock: true,
        imageUrl: '',
      );

      final spec = PrintCatalog.resolveSpec(product: null, variant: variant);

      expect(spec.widthPx, 1200);
      expect(spec.heightPx, 1200);
    });

    test('displayItemsForCategory groups phone cases into one tile', () {
      const products = [
        PrintProduct(
          id: PrintSpecTemplates.phoneCaseProductId,
          title: 'Tough Case for iPhone®',
          typeName: 'Phone Case',
          imageUrl: 'https://example.com/iphone.png',
          variantCount: 54,
        ),
        PrintProduct(
          id: PrintSpecTemplates.samsungPhoneCaseProductId,
          title: 'Tough Case for Samsung®',
          typeName: 'Phone Case',
          imageUrl: 'https://example.com/samsung.png',
          variantCount: 46,
        ),
        PrintProduct(
          id: 505,
          title: 'Jigsaw Puzzle',
          typeName: 'Puzzle',
          imageUrl: '',
          variantCount: 4,
        ),
      ];

      final accessories = PrintCatalog.displayItemsForCategory(
        products,
        PrintProductCategory.accessories,
      );
      final gifts = PrintCatalog.displayItemsForCategory(
        products,
        PrintProductCategory.gifts,
      );

      expect(accessories, hasLength(1));
      final group = accessories.first as PrintCatalogGroupItem;
      expect(group.groupId, PrintCatalog.phoneCaseGroupId);
      expect(group.title, 'Phone cases');
      expect(group.productIds, PrintCatalog.phoneCaseProductIds);
      expect(group.variantCount, 100);
      expect(group.representativeProduct.id,
          PrintSpecTemplates.phoneCaseProductId);

      expect(gifts, hasLength(1));
      expect(gifts.first, isA<PrintCatalogProductItem>());
    });

    test('isPhoneCaseProduct identifies phone case product ids', () {
      expect(PrintCatalog.isPhoneCaseProduct(601), isTrue);
      expect(PrintCatalog.isPhoneCaseProduct(686), isTrue);
      expect(PrintCatalog.isPhoneCaseProduct(71), isFalse);
    });

    test('isDeviceCase identifies phone case products', () {
      expect(PrintCatalog.isDeviceCase(601), isTrue);
      expect(PrintCatalog.isDeviceCase(686), isTrue);
      expect(PrintCatalog.isDeviceCase(71), isFalse);
    });
  });
}
