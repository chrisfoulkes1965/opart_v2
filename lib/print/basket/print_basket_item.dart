import 'package:equatable/equatable.dart';
import 'package:opart_v2/print/models/print_models.dart';

class PrintBasketItem extends Equatable {
  const PrintBasketItem({
    required this.id,
    required this.designId,
    required this.variantId,
    required this.productId,
    required this.productTitle,
    required this.variantLabel,
    required this.addedAt,
    this.mockupUrl,
    this.quantity = 1,
  });

  factory PrintBasketItem.fromJson(Map<String, dynamic> json) {
    return PrintBasketItem(
      id: json['id'] as String,
      designId: json['design_id'] as String,
      variantId: json['variant_id'] as int,
      productId: json['product_id'] as int,
      productTitle: json['product_title'] as String? ?? 'Product',
      variantLabel: json['variant_label'] as String? ?? '',
      mockupUrl: json['mockup_url'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  final String id;
  final String designId;
  final int variantId;
  final int productId;
  final String productTitle;
  final String variantLabel;
  final String? mockupUrl;
  final int quantity;
  final DateTime addedAt;

  String get displayTitle => '$productTitle — $variantLabel';

  BasketLineInput toLineInput() {
    return BasketLineInput(
      variantId: variantId,
      designId: designId,
      quantity: quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'design_id': designId,
      'variant_id': variantId,
      'product_id': productId,
      'product_title': productTitle,
      'variant_label': variantLabel,
      if (mockupUrl != null) 'mockup_url': mockupUrl,
      'quantity': quantity,
      'added_at': addedAt.toIso8601String(),
    };
  }

  PrintBasketItem copyWith({int? quantity}) {
    return PrintBasketItem(
      id: id,
      designId: designId,
      variantId: variantId,
      productId: productId,
      productTitle: productTitle,
      variantLabel: variantLabel,
      mockupUrl: mockupUrl,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        designId,
        variantId,
        productId,
        productTitle,
        variantLabel,
        mockupUrl,
        quantity,
        addedAt,
      ];
}
