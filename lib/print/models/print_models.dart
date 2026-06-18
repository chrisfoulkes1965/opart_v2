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
    required this.printfulSubtotalCents,
    required this.printfulDeliveryCents,
    required this.printfulTaxCents,
    required this.printfulTotalCents,
    required this.retailSubtotalCents,
    required this.retailDeliveryCents,
    required this.retailTaxCents,
    required this.retailTotalCents,
  });

  factory PrintEstimate.fromJson(Map<String, dynamic> json) {
    final retailTotal = json['retail_total_cents'] as int? ?? 0;
    final retailSubtotal = json['retail_subtotal_cents'] as int? ?? retailTotal;
    final retailDelivery = json['retail_delivery_cents'] as int? ??
        json['retail_shipping_cents'] as int? ??
        applyRetailMarkup(json['printful_shipping_cents'] as int? ?? 0);
    final retailTax = json['retail_tax_cents'] as int? ??
        applyRetailMarkup(json['printful_tax_cents'] as int? ?? 0);

    return PrintEstimate(
      currency: json['currency'] as String? ?? 'USD',
      printfulSubtotalCents: json['printful_subtotal_cents'] as int? ?? 0,
      printfulDeliveryCents: json['printful_shipping_cents'] as int? ?? 0,
      printfulTaxCents: json['printful_tax_cents'] as int? ?? 0,
      printfulTotalCents: json['printful_total_cents'] as int? ?? 0,
      retailSubtotalCents: retailSubtotal,
      retailDeliveryCents: retailDelivery,
      retailTaxCents: retailTax,
      retailTotalCents: retailTotal,
    );
  }

  static int applyRetailMarkup(int printfulCents) {
    const markupPercent = 30;
    return (printfulCents * (1 + markupPercent / 100)).round();
  }

  final String currency;
  final int printfulSubtotalCents;
  final int printfulDeliveryCents;
  final int printfulTaxCents;
  final int printfulTotalCents;
  final int retailSubtotalCents;
  final int retailDeliveryCents;
  final int retailTaxCents;
  final int retailTotalCents;

  String formatMoney(int cents) {
    final amount = cents / 100;
    return '${currency.toUpperCase()} ${amount.toStringAsFixed(2)}';
  }

  String get formattedRetailTotal => formatMoney(retailTotalCents);

  bool get hasTax => retailTaxCents > 0;

  @override
  List<Object?> get props => [
        currency,
        printfulSubtotalCents,
        printfulDeliveryCents,
        printfulTaxCents,
        printfulTotalCents,
        retailSubtotalCents,
        retailDeliveryCents,
        retailTaxCents,
        retailTotalCents,
      ];
}

class BasketLineInput extends Equatable {
  const BasketLineInput({
    required this.variantId,
    required this.designId,
    this.quantity = 1,
  });

  final int variantId;
  final String designId;
  final int quantity;

  Map<String, dynamic> toJson() {
    return {
      'variant_id': variantId,
      'design_id': designId,
      'quantity': quantity,
    };
  }

  @override
  List<Object?> get props => [variantId, designId, quantity];
}

class CheckoutLineInput extends Equatable {
  const CheckoutLineInput({
    required this.designId,
    required this.variantId,
    required this.productName,
    this.quantity = 1,
  });

  final String designId;
  final int variantId;
  final String productName;
  final int quantity;

  Map<String, dynamic> toJson() {
    return {
      'design_id': designId,
      'variant_id': variantId,
      'product_name': productName,
      'quantity': quantity,
    };
  }

  @override
  List<Object?> get props => [designId, variantId, productName, quantity];
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

  bool get canEstimate => countryCode.isNotEmpty && zip.isNotEmpty;

  bool get canStartCheckout => canEstimate;

  ShippingAddress copyWith({
    String? name,
    String? address1,
    String? address2,
    String? city,
    String? stateCode,
    String? countryCode,
    String? zip,
    String? email,
    String? phone,
  }) {
    return ShippingAddress(
      name: name ?? this.name,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      stateCode: stateCode ?? this.stateCode,
      countryCode: countryCode ?? this.countryCode,
      zip: zip ?? this.zip,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
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
    required this.clientSecret,
    required this.retailTotalCents,
    required this.currencyCode,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      orderId: json['order_id'] as String,
      clientSecret: json['client_secret'] as String,
      retailTotalCents: json['retail_total_cents'] as int? ?? 0,
      currencyCode: json['currency_code'] as String? ?? 'usd',
    );
  }

  final String orderId;
  final String clientSecret;
  final int retailTotalCents;
  final String currencyCode;

  @override
  List<Object?> get props =>
      [orderId, clientSecret, retailTotalCents, currencyCode];
}
