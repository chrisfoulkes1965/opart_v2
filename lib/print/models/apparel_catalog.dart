import 'package:flutter/material.dart';
import 'package:opart_v2/print/models/print_catalog.dart';
import 'package:opart_v2/print/models/print_models.dart';

class ApparelSelection {
  const ApparelSelection({
    required this.color,
    required this.size,
  });

  final String color;
  final String size;
}

class ApparelCatalog {
  ApparelCatalog._();

  static List<String> uniqueColors(List<PrintVariant> variants) {
    final seen = <String>{};
    final colors = <String>[];

    for (final color in PrintCatalog.apparelPreferredColors) {
      final hasColor = variants.any(
        (variant) => variant.inStock && variant.color == color,
      );
      if (hasColor && seen.add(color)) {
        colors.add(color);
      }
    }

    for (final variant in variants) {
      if (!variant.inStock || variant.color.isEmpty) {
        continue;
      }
      if (seen.add(variant.color)) {
        colors.add(variant.color);
      }
    }

    return colors;
  }

  static List<String> sizesForColor(
    List<PrintVariant> variants, {
    required String color,
  }) {
    final inStockSizes = variants
        .where(
          (variant) =>
              variant.inStock &&
              variant.color == color &&
              variant.size.isNotEmpty,
        )
        .map((variant) => variant.size)
        .toSet();

    final ordered = <String>[];
    for (final size in PrintCatalog.apparelSizeOrder) {
      if (inStockSizes.contains(size)) {
        ordered.add(size);
      }
    }

    final extras = inStockSizes.difference(ordered.toSet()).toList()..sort();
    return [...ordered, ...extras];
  }

  static PrintVariant? variantFor(
    List<PrintVariant> variants, {
    required String color,
    required String size,
  }) {
    for (final variant in variants) {
      if (variant.inStock && variant.color == color && variant.size == size) {
        return variant;
      }
    }
    return null;
  }

  static ApparelSelection? defaultSelection(List<PrintVariant> variants) {
    final colors = uniqueColors(variants);
    if (colors.isEmpty) {
      return null;
    }

    final color = colors.first;
    final sizes = sizesForColor(variants, color: color);
    if (sizes.isEmpty) {
      return null;
    }

    return ApparelSelection(color: color, size: sizes.first);
  }

  static PrintVariant? representativeVariantForColor(
    List<PrintVariant> variants, {
    required String color,
  }) {
    PrintVariant? fallback;
    for (final variant in variants) {
      if (!variant.inStock || variant.color != color) {
        continue;
      }
      fallback ??= variant;
      if (variant.imageUrl.isNotEmpty) {
        return variant;
      }
    }
    return fallback;
  }

  static String? previewImageUrlForColor(
    List<PrintVariant> variants, {
    required String color,
  }) {
    return representativeVariantForColor(variants, color: color)?.imageUrl;
  }

  static String? firstValidSizeForColor(
    List<PrintVariant> variants, {
    required String color,
    String? preferredSize,
  }) {
    final sizes = sizesForColor(variants, color: color);
    if (sizes.isEmpty) {
      return null;
    }
    if (preferredSize != null && sizes.contains(preferredSize)) {
      return preferredSize;
    }
    return sizes.first;
  }

  static Color colorSwatch(String colorName) {
    return switch (colorName) {
      'White' => Colors.white,
      'Black' => Colors.black,
      'Navy' => const Color(0xFF1B2A4A),
      'Red' => const Color(0xFFD32F2F),
      'Dark Grey Heather' => const Color(0xFF4A4A4A),
      'Athletic Heather' => const Color(0xFFB8B8B8),
      'Asphalt' => const Color(0xFF3D3D3D),
      'Forest' => const Color(0xFF2E5E3E),
      'Maroon' => const Color(0xFF6B1F2A),
      'Royal' => const Color(0xFF2B4C9C),
      _ => Colors.grey.shade400,
    };
  }
}
