import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/print_catalog.dart';
import 'package:opart_v2/print/models/print_models.dart';

class PrintVariantStep extends StatelessWidget {
  const PrintVariantStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrintFlowCubit, PrintFlowState>(
      buildWhen: (previous, current) =>
          previous.variants != current.variants ||
          previous.status != current.status ||
          previous.selectedVariant != current.selectedVariant ||
          previous.selectedProduct != current.selectedProduct ||
          previous.productPreviewByProductId !=
              current.productPreviewByProductId,
      builder: (context, state) {
        final product = state.selectedProduct;
        final variants = state.variants;

        if (product == null) {
          return const SizedBox.shrink();
        }

        if (variants.isEmpty) {
          if (state.isBusy) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (state.progressMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      state.progressMessage!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            );
          }

          return const Center(
            child: Text('No sizes in stock for this product.'),
          );
        }

        final productThumb = state.productPreviewByProductId[product.id];

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: variants.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final variant = variants[index];
            return _VariantTile(
              variant: variant,
              product: product,
              productThumb: productThumb,
              isBusy: state.isBusy,
              onTap: () =>
                  context.read<PrintFlowCubit>().selectVariant(variant),
            );
          },
        );
      },
    );
  }
}

class _VariantTile extends StatelessWidget {
  const _VariantTile({
    required this.variant,
    required this.product,
    required this.productThumb,
    required this.isBusy,
    required this.onTap,
  });

  final PrintVariant variant;
  final PrintProduct product;
  final Uint8List? productThumb;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spec = PrintCatalog.resolveSpec(
      product: product,
      variant: variant,
    );

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        leading: _VariantThumb(
          bytes: productThumb,
          aspectRatio: spec.aspectRatio,
        ),
        title: Text(
          variant.displayLabel,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('\$${variant.price}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: isBusy ? null : onTap,
      ),
    );
  }
}

class _VariantThumb extends StatelessWidget {
  const _VariantThumb({
    required this.bytes,
    required this.aspectRatio,
  });

  final Uint8List? bytes;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    const height = 56.0;
    final width = height * aspectRatio.clamp(0.4, 2.5);

    if (bytes == null) {
      return SizedBox(
        width: width,
        height: height,
        child: const ColoredBox(
          color: Color(0xFFEEEEEE),
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.memory(bytes!, fit: BoxFit.cover),
      ),
    );
  }
}
