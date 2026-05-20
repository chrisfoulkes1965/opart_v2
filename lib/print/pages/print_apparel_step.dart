import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/apparel_catalog.dart';
import 'package:opart_v2/print/models/print_catalog.dart';

class PrintApparelStep extends StatelessWidget {
  const PrintApparelStep({super.key});

  static const double _colorPreviewHeight = 220;
  static const double _colorTileImageHeight = 112;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrintFlowCubit, PrintFlowState>(
      buildWhen: (previous, current) =>
          previous.variants != current.variants ||
          previous.status != current.status ||
          previous.selectedProduct != current.selectedProduct ||
          previous.selectedApparelColor != current.selectedApparelColor ||
          previous.selectedApparelSize != current.selectedApparelSize ||
          previous.productPreviewByProductId !=
              current.productPreviewByProductId,
      builder: (context, state) {
        final product = state.selectedProduct;
        if (product == null) {
          return const SizedBox.shrink();
        }

        if (state.variants.isEmpty) {
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
            child: Text('No colours or sizes in stock for this product.'),
          );
        }

        final colors = ApparelCatalog.uniqueColors(state.variants);
        final selectedColor = state.selectedApparelColor;
        final selectedSize = state.selectedApparelSize;
        final sizesInStock = selectedColor == null
            ? const <String>[]
            : ApparelCatalog.sizesForColor(
                state.variants,
                color: selectedColor,
              );
        final resolvedVariant = selectedColor != null && selectedSize != null
            ? ApparelCatalog.variantFor(
                state.variants,
                color: selectedColor,
                size: selectedSize,
              )
            : null;
        final previewColor = selectedColor ?? colors.first;
        final previewImageUrl = ApparelCatalog.previewImageUrlForColor(
          state.variants,
          color: previewColor,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ApparelColorHeroPreview(
                    colorName: previewColor,
                    imageUrl: previewImageUrl,
                    height: _colorPreviewHeight,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Colour',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 12.0;
                      const minTileWidth = 108.0;
                      final columns = (constraints.maxWidth / minTileWidth)
                          .floor()
                          .clamp(2, 4);
                      final tileWidth =
                          (constraints.maxWidth - spacing * (columns - 1)) /
                              columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (final color in colors)
                            SizedBox(
                              width: tileWidth,
                              child: _ApparelColorTile(
                                colorName: color,
                                imageUrl:
                                    ApparelCatalog.previewImageUrlForColor(
                                  state.variants,
                                  color: color,
                                ),
                                imageHeight: _colorTileImageHeight,
                                selected: color == selectedColor,
                                enabled: !state.isBusy,
                                onTap: () => context
                                    .read<PrintFlowCubit>()
                                    .selectApparelColor(color),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Size',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final size in PrintCatalog.apparelSizeOrder)
                        FilterChip(
                          label: Text(size),
                          selected: size == selectedSize,
                          onSelected:
                              sizesInStock.contains(size) && !state.isBusy
                                  ? (_) => context
                                      .read<PrintFlowCubit>()
                                      .selectApparelSize(size)
                                  : null,
                        ),
                    ],
                  ),
                  if (resolvedVariant != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      '\$${resolvedVariant.price}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: FilledButton(
                  onPressed: resolvedVariant != null && !state.isBusy
                      ? () => context
                          .read<PrintFlowCubit>()
                          .confirmApparelSelection()
                      : null,
                  child: const Text('Continue'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ApparelColorHeroPreview extends StatelessWidget {
  const _ApparelColorHeroPreview({
    required this.colorName,
    required this.imageUrl,
    required this.height,
  });

  final String colorName;
  final String? imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: _ApparelColorImage(
              colorName: colorName,
              imageUrl: imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          colorName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ApparelColorTile extends StatelessWidget {
  const _ApparelColorTile({
    required this.colorName,
    required this.imageUrl,
    required this.imageHeight,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String colorName;
  final String? imageUrl;
  final double imageHeight;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? Colors.cyan.shade700 : Colors.grey.shade300;
    final borderWidth = selected ? 2.5 : 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: _ApparelColorImage(
                      colorName: colorName,
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  colorName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ApparelColorImage extends StatelessWidget {
  const _ApparelColorImage({
    required this.colorName,
    required this.imageUrl,
    required this.fit,
  });

  final String colorName;
  final String? imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return ColoredBox(
        color: Colors.grey.shade50,
        child: Image.network(
          url,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _SwatchFallback(
            colorName: colorName,
            large: true,
          ),
        ),
      );
    }

    return _SwatchFallback(colorName: colorName, large: true);
  }
}

class _SwatchFallback extends StatelessWidget {
  const _SwatchFallback({
    required this.colorName,
    this.large = false,
  });

  final String colorName;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final swatch = ApparelCatalog.colorSwatch(colorName);
    final isLight = swatch.computeLuminance() > 0.85;

    return ColoredBox(
      color: swatch,
      child: Center(
        child: Icon(
          Icons.checkroom_outlined,
          size: large ? 56 : 40,
          color: isLight ? Colors.black26 : Colors.white54,
        ),
      ),
    );
  }
}
