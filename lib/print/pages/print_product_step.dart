import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/opart_recipe.dart';
import 'package:opart_v2/print/models/print_catalog.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_product_definition.dart';

class PrintProductStep extends StatelessWidget {
  const PrintProductStep({super.key, required this.products});

  final List<PrintProduct> products;

  static const double _productCardWidth = 112;
  static const double _productImageSize = 96;

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
          if (state.status != PrintFlowStatus.ready) {
            return const SizedBox.shrink();
          }
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

        final sections =
            <PrintProductCategory, List<PrintCatalogDisplayItem>>{};
        for (final category in PrintCatalog.orderedCategories()) {
          final categoryItems =
              PrintCatalog.displayItemsForCategory(products, category);
          if (categoryItems.isNotEmpty) {
            sections[category] = categoryItems;
          }
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _DesignHeader(
              name: OpArtRecipe.displayName(state.recipe),
              previewBytes: state.designPreviewBytes,
            ),
            for (final entry in sections.entries) ...[
              _CategorySection(
                category: entry.key,
                items: entry.value,
                isBusy: state.isBusy,
                onProductSelected: (product) =>
                    context.read<PrintFlowCubit>().selectProduct(product),
                onPhoneCaseGroupSelected: () =>
                    context.read<PrintFlowCubit>().selectPhoneCaseGroup(),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DesignHeader extends StatelessWidget {
  const _DesignHeader({
    required this.name,
    required this.previewBytes,
  });

  final String name;
  final Uint8List? previewBytes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: previewBytes != null
                    ? Image.memory(
                        previewBytes!,
                        fit: BoxFit.cover,
                      )
                    : ColoredBox(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.items,
    required this.isBusy,
    required this.onProductSelected,
    required this.onPhoneCaseGroupSelected,
  });

  final PrintProductCategory category;
  final List<PrintCatalogDisplayItem> items;
  final bool isBusy;
  final void Function(PrintProduct product) onProductSelected;
  final VoidCallback onPhoneCaseGroupSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            category.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: PrintProductStep._productImageSize + 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return switch (item) {
                PrintCatalogProductItem(:final product) => _ProductTile(
                    product: product,
                    title: PrintCatalog.displayTitleFor(product),
                    isBusy: isBusy,
                    onTap: () => onProductSelected(product),
                  ),
                PrintCatalogGroupItem(
                  :final groupId,
                  :final representativeProduct,
                  :final title,
                )
                    when PrintCatalog.isPhoneCaseGroupId(groupId) =>
                  _ProductTile(
                    product: representativeProduct,
                    title: title,
                    isBusy: isBusy,
                    onTap: onPhoneCaseGroupSelected,
                  ),
                PrintCatalogGroupItem(
                  :final representativeProduct,
                  :final title,
                ) =>
                  _ProductTile(
                    product: representativeProduct,
                    title: title,
                    isBusy: isBusy,
                    onTap: () => onProductSelected(representativeProduct),
                  ),
              };
            },
          ),
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.title,
    required this.isBusy,
    required this.onTap,
  });

  final PrintProduct product;
  final String title;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: PrintProductStep._productCardWidth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isBusy ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: PrintProductStep._productImageSize,
                  height: PrintProductStep._productImageSize,
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => ColoredBox(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : ColoredBox(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.shopping_bag_outlined),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
