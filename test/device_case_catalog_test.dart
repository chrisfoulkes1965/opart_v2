import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/print/models/device_case_catalog.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_spec_templates.dart';

void main() {
  group('DeviceCaseCatalog', () {
    final iphoneVariants = [
      const PrintVariant(
        id: 1,
        productId: PrintSpecTemplates.phoneCaseProductId,
        name: 'Tough Case for iPhone 16 Pro Max',
        size: 'iPhone 16 Pro Max',
        color: 'Glossy',
        price: '17.50',
        inStock: true,
        imageUrl: '',
      ),
      const PrintVariant(
        id: 2,
        productId: PrintSpecTemplates.phoneCaseProductId,
        name: 'Tough Case for iPhone 16 Pro Max',
        size: 'iPhone 16 Pro Max',
        color: 'Matte',
        price: '17.50',
        inStock: true,
        imageUrl: '',
      ),
      const PrintVariant(
        id: 3,
        productId: PrintSpecTemplates.phoneCaseProductId,
        name: 'Tough Case for iPhone 15',
        size: 'iPhone 15',
        color: 'Glossy',
        price: '17.50',
        inStock: true,
        imageUrl: '',
      ),
      const PrintVariant(
        id: 4,
        productId: PrintSpecTemplates.phoneCaseProductId,
        name: 'Tough Case for iPhone 14',
        size: 'iPhone 14',
        color: 'Glossy',
        price: '17.50',
        inStock: true,
        imageUrl: '',
      ),
    ];

    test('uniqueModels dedupes by size and sorts newest first', () {
      final models = DeviceCaseCatalog.uniqueModels(iphoneVariants);

      expect(models, [
        'iPhone 16 Pro Max',
        'iPhone 15',
        'iPhone 14',
      ]);
    });

    test('groupModels groups iPhone models by generation', () {
      final models = DeviceCaseCatalog.uniqueModels(iphoneVariants);
      final groups = DeviceCaseCatalog.groupModels(
        models: models,
        brand: PhoneCaseBrand.iphone,
      );

      expect(groups.map((group) => group.title), [
        'iPhone 16 series',
        'iPhone 15 series',
        'iPhone 14 series',
      ]);
      expect(groups.first.models, ['iPhone 16 Pro Max']);
    });

    test('groupModels groups Samsung models by series', () {
      final samsungVariants = [
        const PrintVariant(
          id: 10,
          productId: PrintSpecTemplates.samsungPhoneCaseProductId,
          name: 'Tough Case for Samsung Galaxy S24',
          size: 'Samsung Galaxy S24',
          color: 'Glossy',
          price: '17.50',
          inStock: true,
          imageUrl: '',
        ),
        const PrintVariant(
          id: 11,
          productId: PrintSpecTemplates.samsungPhoneCaseProductId,
          name: 'Tough Case for Samsung Galaxy A54',
          size: 'Samsung Galaxy A54',
          color: 'Glossy',
          price: '17.50',
          inStock: true,
          imageUrl: '',
        ),
      ];

      final models = DeviceCaseCatalog.uniqueModels(samsungVariants);
      final groups = DeviceCaseCatalog.groupModels(
        models: models,
        brand: PhoneCaseBrand.samsung,
      );

      expect(groups.map((group) => group.title), [
        'Galaxy S24 series',
        'Galaxy A54 series',
      ]);
    });

    test('filterModels searches model names', () {
      final models = DeviceCaseCatalog.uniqueModels(iphoneVariants);

      expect(
        DeviceCaseCatalog.filterModels(models, '16 pro'),
        ['iPhone 16 Pro Max'],
      );
      expect(DeviceCaseCatalog.filterModels(models, ''), models);
    });

    test('findVariant resolves finish and model', () {
      final glossy = DeviceCaseCatalog.findVariant(
        variants: iphoneVariants,
        modelSize: 'iPhone 16 Pro Max',
        finish: PhoneCaseFinish.glossy,
      );
      final matte = DeviceCaseCatalog.findVariant(
        variants: iphoneVariants,
        modelSize: 'iPhone 16 Pro Max',
        finish: PhoneCaseFinish.matte,
      );

      expect(glossy?.id, 1);
      expect(matte?.id, 2);
    });

    test('findVariant returns null when finish is out of stock', () {
      final variants = [
        const PrintVariant(
          id: 5,
          productId: PrintSpecTemplates.phoneCaseProductId,
          name: 'Tough Case for iPhone 13',
          size: 'iPhone 13',
          color: 'Glossy',
          price: '17.50',
          inStock: true,
          imageUrl: '',
        ),
        const PrintVariant(
          id: 6,
          productId: PrintSpecTemplates.phoneCaseProductId,
          name: 'Tough Case for iPhone 13',
          size: 'iPhone 13',
          color: 'Matte',
          price: '17.50',
          inStock: false,
          imageUrl: '',
        ),
      ];

      expect(
        DeviceCaseCatalog.isAvailableForFinish(
          variants: variants,
          modelSize: 'iPhone 13',
          finish: PhoneCaseFinish.glossy,
        ),
        isTrue,
      );
      expect(
        DeviceCaseCatalog.isAvailableForFinish(
          variants: variants,
          modelSize: 'iPhone 13',
          finish: PhoneCaseFinish.matte,
        ),
        isFalse,
      );
      expect(
        DeviceCaseCatalog.findVariant(
          variants: variants,
          modelSize: 'iPhone 13',
          finish: PhoneCaseFinish.matte,
        ),
        isNull,
      );
    });

    test('PhoneCaseBrand.forProductId maps product ids', () {
      expect(
        PhoneCaseBrand.forProductId(PrintSpecTemplates.phoneCaseProductId),
        PhoneCaseBrand.iphone,
      );
      expect(
        PhoneCaseBrand.forProductId(
          PrintSpecTemplates.samsungPhoneCaseProductId,
        ),
        PhoneCaseBrand.samsung,
      );
    });
  });
}
