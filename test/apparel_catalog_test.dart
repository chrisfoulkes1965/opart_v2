import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/print/models/apparel_catalog.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_spec_templates.dart';

void main() {
  group('ApparelCatalog', () {
    const variants = [
      PrintVariant(
        id: 1,
        productId: PrintSpecTemplates.tShirtProductId,
        name: 'White / M',
        size: 'M',
        color: 'White',
        price: '14.99',
        inStock: true,
        imageUrl: '',
      ),
      PrintVariant(
        id: 2,
        productId: PrintSpecTemplates.tShirtProductId,
        name: 'White / L',
        size: 'L',
        color: 'White',
        price: '14.99',
        inStock: true,
        imageUrl: '',
      ),
      PrintVariant(
        id: 3,
        productId: PrintSpecTemplates.tShirtProductId,
        name: 'Red / S',
        size: 'S',
        color: 'Red',
        price: '14.99',
        inStock: true,
        imageUrl: '',
      ),
      PrintVariant(
        id: 4,
        productId: PrintSpecTemplates.tShirtProductId,
        name: 'Black / M',
        size: 'M',
        color: 'Black',
        price: '14.99',
        inStock: false,
        imageUrl: '',
      ),
    ];

    test('uniqueColors returns in-stock colors in catalog order', () {
      expect(ApparelCatalog.uniqueColors(variants), ['White', 'Red']);
    });

    test('sizesForColor returns ordered in-stock sizes', () {
      expect(
        ApparelCatalog.sizesForColor(variants, color: 'White'),
        ['M', 'L'],
      );
      expect(
        ApparelCatalog.sizesForColor(variants, color: 'Red'),
        ['S'],
      );
    });

    test('variantFor resolves matching variant', () {
      final variant = ApparelCatalog.variantFor(
        variants,
        color: 'White',
        size: 'L',
      );

      expect(variant?.id, 2);
    });

    test('defaultSelection picks first color and size', () {
      final selection = ApparelCatalog.defaultSelection(variants);

      expect(selection?.color, 'White');
      expect(selection?.size, 'M');
    });

    test('previewImageUrlForColor returns variant product image', () {
      const withImage = PrintVariant(
        id: 10,
        productId: PrintSpecTemplates.tShirtProductId,
        name: 'Navy / M',
        size: 'M',
        color: 'Navy',
        price: '14.99',
        inStock: true,
        imageUrl: 'https://example.com/navy-tee.png',
      );

      expect(
        ApparelCatalog.previewImageUrlForColor(
          [...variants, withImage],
          color: 'Navy',
        ),
        'https://example.com/navy-tee.png',
      );
    });

    test('firstValidSizeForColor keeps preferred size when available', () {
      expect(
        ApparelCatalog.firstValidSizeForColor(
          variants,
          color: 'White',
          preferredSize: 'L',
        ),
        'L',
      );
      expect(
        ApparelCatalog.firstValidSizeForColor(
          variants,
          color: 'White',
          preferredSize: 'XL',
        ),
        'M',
      );
    });
  });
}
