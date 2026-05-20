import 'package:flutter/material.dart';
import 'package:opart_v2/print/models/print_placement.dart';

/// Crop-window geometry for fixed artwork + movable selection rectangle.
class PrintCropGeometry {
  PrintCropGeometry._();

  static const double minSizeFraction = 0.2;
  static const double viewportPadding = 16;

  /// Largest [frameAspectRatio] rect that fits inside [viewportSize].
  static Rect artworkRectForFrame({
    required Size viewportSize,
    required double frameAspectRatio,
    double padding = viewportPadding,
  }) {
    final maxWidth =
        (viewportSize.width - padding * 2).clamp(0.0, double.infinity);
    final maxHeight =
        (viewportSize.height - padding * 2).clamp(0.0, double.infinity);

    var width = maxWidth;
    var height = width / frameAspectRatio;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * frameAspectRatio;
    }

    return Rect.fromLTWH(
      (viewportSize.width - width) / 2,
      (viewportSize.height - height) / 2,
      width,
      height,
    );
  }

  /// Largest crop size (normalized 0–1) for [cropAspectRatio] inside a frame.
  static Size maxCropSizeNormalized({
    required double frameAspectRatio,
    required double cropAspectRatio,
  }) {
    if (cropAspectRatio >= frameAspectRatio) {
      return Size(1, frameAspectRatio / cropAspectRatio);
    }
    return Size(cropAspectRatio / frameAspectRatio, 1);
  }

  static Size cropSizeNormalized({
    required double frameAspectRatio,
    required double cropAspectRatio,
    required double sizeFraction,
  }) {
    final max = maxCropSizeNormalized(
      frameAspectRatio: frameAspectRatio,
      cropAspectRatio: cropAspectRatio,
    );
    final fraction = sizeFraction.clamp(minSizeFraction, 1.0);
    return Size(max.width * fraction, max.height * fraction);
  }

  /// Crop rect in frame-local pixel coordinates.
  static Rect cropRectInFrame({
    required PrintPlacement placement,
    required double frameWidth,
    required double frameHeight,
    required double cropAspectRatio,
  }) {
    final frameAspect = frameWidth / frameHeight;
    final sizeNorm = cropSizeNormalized(
      frameAspectRatio: frameAspect,
      cropAspectRatio: cropAspectRatio,
      sizeFraction: placement.size,
    );
    final clamped = clampPlacement(
      placement: placement,
      frameAspectRatio: frameAspect,
      cropAspectRatio: cropAspectRatio,
    );
    final width = sizeNorm.width * frameWidth;
    final height = sizeNorm.height * frameHeight;
    final cx = clamped.centerX * frameWidth;
    final cy = clamped.centerY * frameHeight;

    return Rect.fromLTWH(cx - width / 2, cy - height / 2, width, height);
  }

  /// Crop rect in viewport coordinates.
  static Rect cropRectInViewport({
    required PrintPlacement placement,
    required Rect artworkRect,
    required double frameWidth,
    required double frameHeight,
    required double cropAspectRatio,
  }) {
    final cropFrame = cropRectInFrame(
      placement: placement,
      frameWidth: frameWidth,
      frameHeight: frameHeight,
      cropAspectRatio: cropAspectRatio,
    );
    final scale = artworkRect.width / frameWidth;

    return Rect.fromLTWH(
      artworkRect.left + cropFrame.left * scale,
      artworkRect.top + cropFrame.top * scale,
      cropFrame.width * scale,
      cropFrame.height * scale,
    );
  }

  static PrintPlacement clampPlacement({
    required PrintPlacement placement,
    required double frameAspectRatio,
    required double cropAspectRatio,
  }) {
    final size = cropSizeNormalized(
      frameAspectRatio: frameAspectRatio,
      cropAspectRatio: cropAspectRatio,
      sizeFraction: placement.size,
    );
    final halfW = size.width / 2;
    final halfH = size.height / 2;

    return PrintPlacement(
      centerX: placement.centerX.clamp(halfW, 1.0 - halfW),
      centerY: placement.centerY.clamp(halfH, 1.0 - halfH),
      size: placement.size.clamp(minSizeFraction, 1.0),
    );
  }

  static Offset viewportToArtworkNormalized({
    required Offset viewportPoint,
    required Rect artworkRect,
  }) {
    if (artworkRect.width <= 0 || artworkRect.height <= 0) {
      return Offset.zero;
    }
    return Offset(
      ((viewportPoint.dx - artworkRect.left) / artworkRect.width)
          .clamp(0.0, 1.0),
      ((viewportPoint.dy - artworkRect.top) / artworkRect.height)
          .clamp(0.0, 1.0),
    );
  }

  static PrintPlacement applyPan({
    required PrintPlacement start,
    required Offset deltaViewport,
    required Rect artworkRect,
    required double frameAspectRatio,
    required double cropAspectRatio,
  }) {
    if (artworkRect.width <= 0) {
      return start;
    }
    final normalizedDelta = Offset(
      deltaViewport.dx / artworkRect.width,
      deltaViewport.dy / artworkRect.height,
    );
    return clampPlacement(
      placement: start.copyWith(
        centerX: start.centerX + normalizedDelta.dx,
        centerY: start.centerY + normalizedDelta.dy,
      ),
      frameAspectRatio: frameAspectRatio,
      cropAspectRatio: cropAspectRatio,
    );
  }

  static PrintPlacement applyPinch({
    required PrintPlacement start,
    required double gestureScale,
    required Offset anchorNormalized,
    required double frameAspectRatio,
    required double cropAspectRatio,
  }) {
    const frameWidth = 1.0;
    const frameHeight = 1.0;
    final startCrop = cropRectInFrame(
      placement: start,
      frameWidth: frameWidth,
      frameHeight: frameHeight,
      cropAspectRatio: cropAspectRatio,
    );

    final u = startCrop.width > 0
        ? ((anchorNormalized.dx - startCrop.left) / startCrop.width)
            .clamp(0.0, 1.0)
        : 0.5;
    final v = startCrop.height > 0
        ? ((anchorNormalized.dy - startCrop.top) / startCrop.height)
            .clamp(0.0, 1.0)
        : 0.5;

    final newSize = (start.size * gestureScale).clamp(minSizeFraction, 1.0);
    final newDimensions = cropSizeNormalized(
      frameAspectRatio: frameAspectRatio,
      cropAspectRatio: cropAspectRatio,
      sizeFraction: newSize,
    );

    final newLeft = anchorNormalized.dx - u * newDimensions.width;
    final newTop = anchorNormalized.dy - v * newDimensions.height;
    final newCenterX = newLeft + newDimensions.width / 2;
    final newCenterY = newTop + newDimensions.height / 2;

    return clampPlacement(
      placement: PrintPlacement(
        centerX: newCenterX,
        centerY: newCenterY,
        size: newSize,
      ),
      frameAspectRatio: frameAspectRatio,
      cropAspectRatio: cropAspectRatio,
    );
  }

  static PrintPlacement applyScaleGesture({
    required PrintPlacement start,
    required Offset startFocalNormalized,
    required Offset currentFocalNormalized,
    required double gestureScale,
    required double frameAspectRatio,
    required double cropAspectRatio,
  }) {
    var placement = start;

    if ((gestureScale - 1).abs() > 0.001) {
      placement = applyPinch(
        start: placement,
        gestureScale: gestureScale,
        anchorNormalized: startFocalNormalized,
        frameAspectRatio: frameAspectRatio,
        cropAspectRatio: cropAspectRatio,
      );
    }

    final panNormalized = Offset(
      currentFocalNormalized.dx - startFocalNormalized.dx,
      currentFocalNormalized.dy - startFocalNormalized.dy,
    );

    if (panNormalized != Offset.zero) {
      placement = clampPlacement(
        placement: placement.copyWith(
          centerX: placement.centerX + panNormalized.dx,
          centerY: placement.centerY + panNormalized.dy,
        ),
        frameAspectRatio: frameAspectRatio,
        cropAspectRatio: cropAspectRatio,
      );
    }

    return placement;
  }
}
