import 'package:equatable/equatable.dart';

class PrintProduct extends Equatable {
  const PrintProduct({
    required this.id,
    required this.title,
    required this.typeName,
    required this.imageUrl,
    required this.variantCount,
  });

  factory PrintProduct.fromJson(Map<String, dynamic> json) {
    return PrintProduct(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Product',
      typeName: json['type_name'] as String? ?? '',
      imageUrl: json['image'] as String? ?? '',
      variantCount: json['variant_count'] as int? ?? 0,
    );
  }

  final int id;
  final String title;
  final String typeName;
  final String imageUrl;
  final int variantCount;

  @override
  List<Object?> get props => [id, title, typeName, imageUrl, variantCount];
}

class PrintVariant extends Equatable {
  const PrintVariant({
    required this.id,
    required this.productId,
    required this.name,
    required this.size,
    required this.color,
    required this.price,
    required this.inStock,
    required this.imageUrl,
  });

  factory PrintVariant.fromJson(Map<String, dynamic> json) {
    return PrintVariant(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      name: json['name'] as String? ?? '',
      size: json['size'] as String? ?? '',
      color: json['color'] as String? ?? '',
      price: json['price'] as String? ?? '0',
      inStock: json['in_stock'] as bool? ?? true,
      imageUrl: json['image'] as String? ?? '',
    );
  }

  final int id;
  final int productId;
  final String name;
  final String size;
  final String color;
  final String price;
  final bool inStock;
  final String imageUrl;

  String get displayLabel {
    if (color.isNotEmpty && size.isNotEmpty) {
      return '$color · $size';
    }
    if (size.isNotEmpty) {
      return size;
    }
    return name;
  }

  @override
  List<Object?> get props =>
      [id, productId, name, size, color, price, inStock, imageUrl];
}

class PrintMockup extends Equatable {
  const PrintMockup({
    required this.mockupUrl,
    required this.variantIds,
  });

  factory PrintMockup.fromJson(Map<String, dynamic> json) {
    return PrintMockup(
      mockupUrl: json['mockup_url'] as String? ?? '',
      variantIds: (json['variant_ids'] as List<dynamic>? ?? [])
          .map((id) => id as int)
          .toList(),
    );
  }

  final String mockupUrl;
  final List<int> variantIds;

  @override
  List<Object?> get props => [mockupUrl, variantIds];
}

class PrintEstimate extends Equatable {
  const PrintEstimate({
    required this.currency,
    required this.printfulTotalCents,
    required this.retailTotalCents,
    required this.printfulShippingCents,
  });

  factory PrintEstimate.fromJson(Map<String, dynamic> json) {
    return PrintEstimate(
      currency: json['currency'] as String? ?? 'USD',
      printfulTotalCents: json['printful_total_cents'] as int? ?? 0,
      retailTotalCents: json['retail_total_cents'] as int? ?? 0,
      printfulShippingCents: json['printful_shipping_cents'] as int? ?? 0,
    );
  }

  final String currency;
  final int printfulTotalCents;
  final int retailTotalCents;
  final int printfulShippingCents;

  String get formattedRetailTotal {
    final amount = retailTotalCents / 100;
    return '${currency.toUpperCase()} ${amount.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props =>
      [currency, printfulTotalCents, retailTotalCents, printfulShippingCents];
}

class ShippingAddress extends Equatable {
  const ShippingAddress({
    required this.name,
    required this.address1,
    required this.city,
    required this.stateCode,
    required this.countryCode,
    required this.zip,
    required this.email,
    this.address2 = '',
    this.phone = '',
  });

  final String name;
  final String address1;
  final String address2;
  final String city;
  final String stateCode;
  final String countryCode;
  final String zip;
  final String email;
  final String phone;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address1': address1,
      'address2': address2,
      'city': city,
      'state_code': stateCode,
      'country_code': countryCode,
      'zip': zip,
      'email': email,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [
        name,
        address1,
        address2,
        city,
        stateCode,
        countryCode,
        zip,
        email,
        phone
      ];
}

class PrintOrderSummary extends Equatable {
  const PrintOrderSummary({
    required this.id,
    required this.status,
    this.trackingUrl,
    this.productName,
    this.retailTotalCents,
  });

  factory PrintOrderSummary.fromJson(Map<String, dynamic> json) {
    return PrintOrderSummary(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'pending',
      trackingUrl: json['tracking_url'] as String?,
      productName: json['product_name'] as String?,
      retailTotalCents: json['retail_total_cents'] as int?,
    );
  }

  final String id;
  final String status;
  final String? trackingUrl;
  final String? productName;
  final int? retailTotalCents;

  @override
  List<Object?> get props =>
      [id, status, trackingUrl, productName, retailTotalCents];
}

class RegisteredDesign extends Equatable {
  const RegisteredDesign({
    required this.designId,
  });

  final String designId;

  @override
  List<Object?> get props => [designId];
}

class CheckoutSession extends Equatable {
  const CheckoutSession({
    required this.orderId,
    required this.checkoutUrl,
    required this.retailTotalCents,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      orderId: json['order_id'] as String,
      checkoutUrl: json['checkout_url'] as String,
      retailTotalCents: json['retail_total_cents'] as int? ?? 0,
    );
  }

  final String orderId;
  final String checkoutUrl;
  final int retailTotalCents;

  @override
  List<Object?> get props => [orderId, checkoutUrl, retailTotalCents];
}
