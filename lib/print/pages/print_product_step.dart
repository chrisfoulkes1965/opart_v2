import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/print_catalog.dart';
import 'package:opart_v2/print/models/print_models.dart';

class PrintProductStep extends StatelessWidget {
  const PrintProductStep({super.key, required this.products});

  final List<PrintProduct> products;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrintFlowCubit, PrintFlowState>(
      builder: (context, state) {
        if (!state.hasValidRecipe) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Create and save a design before printing.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No print products are available yet. Check your Printful configuration.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            final previewBytes = state.productPreviewByProductId[product.id];
            final aspectRatio =
                PrintCatalog.canonicalPreviewSpec(product.id).aspectRatio;

            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: state.isBusy
                    ? null
                    : () =>
                        context.read<PrintFlowCubit>().selectProduct(product),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProductDesignPreview(
                        previewBytes: previewBytes,
                        aspectRatio: aspectRatio,
                        catalogImageUrl: product.imageUrl,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(product.typeName),
                            Text(PrintCatalog.variantSubtitle(product)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductDesignPreview extends StatelessWidget {
  const _ProductDesignPreview({
    required this.previewBytes,
    required this.aspectRatio,
    required this.catalogImageUrl,
  });

  final Uint8List? previewBytes;
  final double aspectRatio;
  final String catalogImageUrl;

  @override
  Widget build(BuildContext context) {
    const height = 88.0;
    final width = (height * aspectRatio).clamp(72.0, 120.0);

    return SizedBox(
      width: width + 28,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (previewBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: width,
                height: height,
                child: Image.memory(
                  previewBytes!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            SizedBox(
              width: width,
              height: height,
              child: ColoredBox(
                color: Colors.grey.shade200,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          if (catalogImageUrl.isNotEmpty)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    catalogImageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.shopping_bag_outlined, size: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
