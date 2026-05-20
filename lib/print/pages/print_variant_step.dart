import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/print_catalog.dart';

class PrintVariantStep extends StatelessWidget {
  const PrintVariantStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrintFlowCubit, PrintFlowState>(
      buildWhen: (previous, current) =>
          previous.variants != current.variants ||
          previous.selectedVariant != current.selectedVariant ||
          previous.productPreviewByProductId !=
              current.productPreviewByProductId,
      builder: (context, state) {
        final product = state.selectedProduct;
        final variants = state.variants;

        if (product == null) {
          return const SizedBox.shrink();
        }

        if (variants.isEmpty) {
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
                onTap: state.isBusy
                    ? null
                    : () =>
                        context.read<PrintFlowCubit>().selectVariant(variant),
              ),
            );
          },
        );
      },
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
