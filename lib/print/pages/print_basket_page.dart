import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/basket/print_basket_cubit.dart';
import 'package:opart_v2/print/basket/print_basket_state.dart';
import 'package:opart_v2/print/pages/print_basket_checkout_page.dart';

class PrintBasketPage extends StatelessWidget {
  const PrintBasketPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const PrintBasketPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan.withValues(alpha: 0.85),
        title: const Text(
          'Basket',
          style: TextStyle(
            fontFamily: 'Righteous',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: BlocBuilder<PrintBasketCubit, PrintBasketState>(
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your basket is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add prints from the shop when you preview a design.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to shop'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Card(
                      child: ListTile(
                        leading:
                            item.mockupUrl != null && item.mockupUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.mockupUrl!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image_outlined),
                                    ),
                                  )
                                : const Icon(Icons.image_outlined),
                        title: Text(item.productTitle),
                        subtitle: Text(
                          item.quantity > 1
                              ? '${item.variantLabel} × ${item.quantity}'
                              : item.variantLabel,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              context.read<PrintBasketCubit>().remove(item.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => PrintBasketCheckoutPage.open(context),
                  child: Text(
                    'Checkout (${state.itemCount} ${state.itemCount == 1 ? 'item' : 'items'})',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
