import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:opart_v2/print/models/opart_recipe.dart';
import 'package:opart_v2/print/models/print_placement.dart';
import 'package:opart_v2/print/models/print_raster_artwork.dart';
import 'package:opart_v2/print/models/print_spec.dart';
import 'package:opart_v2/print/services/print_artwork_bounds.dart';
import 'package:opart_v2/print/services/print_crop_geometry.dart';

/// Renders a design once to a flat square bitmap for crop UI and export.
class PrintArtworkRasterService {
  PrintArtworkRasterService();

  /// Square pixel size for the master artwork bitmap.
  static const int canonicalSidePx = 2048;

  PrintRasterArtwork? _cachedArtwork;
  String? _cachedRecipeKey;

  /// Returns cached flattened artwork with tight content bounds.
  Future<PrintRasterArtwork> artwork(Map<String, dynamic> recipe) async {
    final key = OpArtRecipe.rasterCacheKey(recipe);
    if (_cachedArtwork != null && _cachedRecipeKey == key) {
      return _cachedArtwork!;
    }

    _cachedArtwork?.image.dispose();
    _cachedArtwork = await _render(recipe);
    _cachedRecipeKey = key;
    return _cachedArtwork!;
  }

  /// Backwards-compatible accessor for the raw bitmap.
  Future<ui.Image> artworkImage(Map<String, dynamic> recipe) async {
    final raster = await artwork(recipe);
    return raster.image;
  }

  void clearCache() {
    _cachedArtwork?.image.dispose();
    _cachedArtwork = null;
    _cachedRecipeKey = null;
  }

  Future<PrintRasterArtwork> _render(Map<String, dynamic> recipe) async {
    final side = canonicalSidePx;
    final opArt = OpArtRecipe.toOpArtForPrint(recipe);
    final seed = OpArtRecipe.seedFrom(recipe);
    final animationValue = OpArtRecipe.animationValueFrom(recipe);
    final backgroundColor = OpArtRecipe.backgroundColorFrom(opArt);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    opArt.paint(
      canvas,
      Size(side.toDouble(), side.toDouble()),
      seed,
      animationValue,
    );

    final picture = recorder.endRecording();
    ui.Image image;
    try {
      image = await picture.toImage(side, side);
    } finally {
      picture.dispose();
    }

    final contentRect = await PrintArtworkBounds.detectContentRect(
      image,
      backgroundColor: backgroundColor,
    );

    return PrintRasterArtwork(
      image: image,
      contentRect: contentRect,
    );
  }

  /// Crops [placement] from the content region into a print-sized PNG.
  Future<Uint8List> cropToPng({
    required PrintRasterArtwork artwork,
    required PrintSpec spec,
    required PrintPlacement placement,
  }) async {
    final exportWidth = spec.widthPx;
    final exportHeight = spec.heightPx;
    final content = artwork.contentRect;

    final cropInContent = PrintCropGeometry.cropRectInFrame(
      placement: placement,
      frameWidth: content.width,
      frameHeight: content.height,
      cropAspectRatio: spec.aspectRatio,
    );

    final cropInSource = Rect.fromLTWH(
      content.left + cropInContent.left,
      content.top + cropInContent.top,
      cropInContent.width,
      cropInContent.height,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      artwork.image,
      cropInSource,
      Rect.fromLTWH(
        0,
        0,
        exportWidth.toDouble(),
        exportHeight.toDouble(),
      ),
      Paint(),
    );

    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(exportWidth, exportHeight);
      try {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          throw StateError('Failed to encode print PNG');
        }
        return byteData.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  Future<Uint8List> renderRecipeToPng({
    required Map<String, dynamic> recipe,
    required PrintSpec spec,
    PrintPlacement placement = PrintPlacement.initial,
  }) async {
    final raster = await artwork(recipe);
    return cropToPng(
      artwork: raster,
      spec: spec,
      placement: placement,
    );
  }
}
