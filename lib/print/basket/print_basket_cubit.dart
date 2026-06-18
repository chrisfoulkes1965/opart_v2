import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/basket/print_basket_item.dart';
import 'package:opart_v2/print/basket/print_basket_repository.dart';
import 'package:opart_v2/print/basket/print_basket_state.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:uuid/uuid.dart';

class PrintBasketCubit extends Cubit<PrintBasketState> {
  PrintBasketCubit({PrintBasketRepository? repository})
      : _repository = repository ?? PrintBasketRepository(),
        super(const PrintBasketState()) {
    unawaited(_load());
  }

  final PrintBasketRepository _repository;
  final _uuid = const Uuid();

  Future<void> _load() async {
    final items = await _repository.loadItems();
    final savedAddress = await _repository.loadShippingAddress();
    emit(
      PrintBasketState(
        items: items,
        shippingAddress: savedAddress ?? PrintFlowState.defaultShippingAddress,
        isLoaded: true,
      ),
    );
  }

  Future<void> addFromFlow({
    required String designId,
    required int variantId,
    required int productId,
    required String productTitle,
    required String variantLabel,
    String? mockupUrl,
  }) async {
    final existingIndex = state.items.indexWhere(
      (item) => item.designId == designId && item.variantId == variantId,
    );

    final List<PrintBasketItem> updated;
    if (existingIndex >= 0) {
      updated = List<PrintBasketItem>.from(state.items);
      final existing = updated[existingIndex];
      updated[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
    } else {
      updated = [
        ...state.items,
        PrintBasketItem(
          id: _uuid.v4(),
          designId: designId,
          variantId: variantId,
          productId: productId,
          productTitle: productTitle,
          variantLabel: variantLabel,
          mockupUrl: mockupUrl,
          addedAt: DateTime.now(),
        ),
      ];
    }

    await _persist(updated);
  }

  Future<void> remove(String itemId) async {
    final updated =
        state.items.where((item) => item.id != itemId).toList(growable: false);
    await _persist(updated);
  }

  Future<void> clear() async {
    await _persist([]);
  }

  Future<void> updateShippingAddress(ShippingAddress address) async {
    emit(state.copyWith(shippingAddress: address));
    await _repository.saveShippingAddress(address);
  }

  Future<void> _persist(List<PrintBasketItem> items) async {
    emit(state.copyWith(items: items));
    await _repository.saveItems(items);
  }

  List<BasketLineInput> get lineInputs =>
      state.items.map((item) => item.toLineInput()).toList();

  List<String> get itemLabels =>
      state.items.map((item) => item.displayTitle).toList();
}
