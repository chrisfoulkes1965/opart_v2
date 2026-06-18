import 'package:equatable/equatable.dart';
import 'package:opart_v2/print/basket/print_basket_item.dart';
import 'package:opart_v2/print/models/print_models.dart';

class PrintBasketState extends Equatable {
  const PrintBasketState({
    this.items = const [],
    ShippingAddress? shippingAddress,
    this.isLoaded = false,
  }) : shippingAddress = shippingAddress ?? _emptyAddress;

  static const ShippingAddress _emptyAddress = ShippingAddress(
    name: '',
    address1: '',
    city: '',
    stateCode: '',
    countryCode: '',
    zip: '',
    email: '',
  );

  final List<PrintBasketItem> items;
  final ShippingAddress shippingAddress;
  final bool isLoaded;

  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  PrintBasketState copyWith({
    List<PrintBasketItem>? items,
    ShippingAddress? shippingAddress,
    bool? isLoaded,
  }) {
    return PrintBasketState(
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [items, shippingAddress, isLoaded];
}
