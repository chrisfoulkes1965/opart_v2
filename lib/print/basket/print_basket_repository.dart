import 'dart:convert';

import 'package:opart_v2/print/basket/print_basket_item.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrintBasketRepository {
  static const _itemsKey = 'print_basket_v1';
  static const _addressKey = 'print_basket_address_v1';

  Future<List<PrintBasketItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_itemsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => PrintBasketItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveItems(List<PrintBasketItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_itemsKey, encoded);
  }

  Future<ShippingAddress?> loadShippingAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_addressKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return ShippingAddress(
      name: map['name'] as String? ?? '',
      address1: map['address1'] as String? ?? '',
      address2: map['address2'] as String? ?? '',
      city: map['city'] as String? ?? '',
      stateCode: map['state_code'] as String? ?? '',
      countryCode: map['country_code'] as String? ??
          PrintFlowState.defaultShippingAddress.countryCode,
      zip: map['zip'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
    );
  }

  Future<void> saveShippingAddress(ShippingAddress address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_addressKey, jsonEncode(address.toJson()));
  }
}
