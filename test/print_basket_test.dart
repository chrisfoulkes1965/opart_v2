import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/print/basket/print_basket_item.dart';

void main() {
  group('PrintBasketItem', () {
    test('round-trips through JSON', () {
      final addedAt = DateTime.utc(2026, 5, 20, 12);
      final item = PrintBasketItem(
        id: 'item-1',
        designId: 'design-1',
        variantId: 42,
        productId: 7,
        productTitle: 'Poster',
        variantLabel: '12×16',
        mockupUrl: 'https://example.com/mockup.png',
        quantity: 2,
        addedAt: addedAt,
      );

      final restored = PrintBasketItem.fromJson(item.toJson());

      expect(restored.id, item.id);
      expect(restored.designId, item.designId);
      expect(restored.variantId, item.variantId);
      expect(restored.quantity, 2);
      expect(restored.displayTitle, 'Poster — 12×16');
    });
  });
}
