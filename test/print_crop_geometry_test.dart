import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/print/models/print_placement.dart';
import 'package:opart_v2/print/services/print_crop_geometry.dart';

void main() {
  group('PrintCropGeometry', () {
    test('artworkRectForFrame fits content aspect in viewport', () {
      const viewport = Size(400, 600);
      const frameAspect = 0.75;

      final rect = PrintCropGeometry.artworkRectForFrame(
        viewportSize: viewport,
        frameAspectRatio: frameAspect,
      );

      expect(rect.width / rect.height, closeTo(frameAspect, 0.001));
      expect(rect.center.dx, closeTo(viewport.width / 2, 0.001));
      expect(rect.center.dy, closeTo(viewport.height / 2, 0.001));
    });

    test('maxCropSizeNormalized respects aspects', () {
      final portraitFrame = PrintCropGeometry.maxCropSizeNormalized(
        frameAspectRatio: 0.75,
        cropAspectRatio: 0.75,
      );
      expect(portraitFrame.width, closeTo(1, 0.001));
      expect(portraitFrame.height, closeTo(1, 0.001));

      final landscapeCrop = PrintCropGeometry.maxCropSizeNormalized(
        frameAspectRatio: 0.75,
        cropAspectRatio: 2.0,
      );
      expect(landscapeCrop.width, closeTo(1, 0.001));
      expect(landscapeCrop.height, lessThan(1));
    });

    test('initial placement is centered at max size', () {
      const placement = PrintPlacement.initial;
      const frameWidth = 300.0;
      const frameHeight = 400.0;
      const cropAspect = 0.75;

      final crop = PrintCropGeometry.cropRectInFrame(
        placement: placement,
        frameWidth: frameWidth,
        frameHeight: frameHeight,
        cropAspectRatio: cropAspect,
      );

      expect(crop.center.dx, closeTo(frameWidth / 2, 0.001));
      expect(crop.center.dy, closeTo(frameHeight / 2, 0.001));
      expect(crop.width / crop.height, closeTo(cropAspect, 0.001));
      expect(crop.height, frameHeight);
    });

    test('applyPan moves crop center', () {
      const start = PrintPlacement(centerX: 0.5, centerY: 0.5, size: 0.8);
      const artworkRect = Rect.fromLTWH(50, 100, 300, 400);
      const frameAspect = 0.75;
      const cropAspect = 0.75;

      final moved = PrintCropGeometry.applyPan(
        start: start,
        deltaViewport: const Offset(30, 0),
        artworkRect: artworkRect,
        frameAspectRatio: frameAspect,
        cropAspectRatio: cropAspect,
      );

      expect(moved.centerX, greaterThan(start.centerX));
      expect(moved.centerY, start.centerY);
    });

    test('applyPinch shrinks crop while keeping anchor stable', () {
      const start = PrintPlacement.initial;
      const anchor = Offset(0.5, 0.5);
      const frameAspect = 0.75;
      const cropAspect = 0.75;

      final zoomedOut = PrintCropGeometry.applyPinch(
        start: start,
        gestureScale: 0.5,
        anchorNormalized: anchor,
        frameAspectRatio: frameAspect,
        cropAspectRatio: cropAspect,
      );

      expect(zoomedOut.size, closeTo(0.5, 0.001));
      expect(zoomedOut.centerX, closeTo(0.5, 0.001));
      expect(zoomedOut.centerY, closeTo(0.5, 0.001));
    });

    test('clampPlacement keeps crop inside frame bounds', () {
      const placement = PrintPlacement(centerX: 0.05, centerY: 0.95, size: 1);
      const frameAspect = 0.75;
      const cropAspect = 0.75;

      final clamped = PrintCropGeometry.clampPlacement(
        placement: placement,
        frameAspectRatio: frameAspect,
        cropAspectRatio: cropAspect,
      );

      final crop = PrintCropGeometry.cropRectInFrame(
        placement: clamped,
        frameWidth: 300,
        frameHeight: 400,
        cropAspectRatio: cropAspect,
      );

      expect(crop.left, greaterThanOrEqualTo(0));
      expect(crop.top, greaterThanOrEqualTo(0));
      expect(crop.right, lessThanOrEqualTo(300));
      expect(crop.bottom, lessThanOrEqualTo(400));
    });

    test('crop proportions match between UI and export frame sizes', () {
      const placement = PrintPlacement(centerX: 0.4, centerY: 0.6, size: 0.7);
      const cropAspect = 0.75;

      final uiCrop = PrintCropGeometry.cropRectInFrame(
        placement: placement,
        frameWidth: 320,
        frameHeight: 426,
        cropAspectRatio: cropAspect,
      );
      final exportCrop = PrintCropGeometry.cropRectInFrame(
        placement: placement,
        frameWidth: 1536,
        frameHeight: 2048,
        cropAspectRatio: cropAspect,
      );

      expect(uiCrop.left / 320, closeTo(exportCrop.left / 1536, 0.001));
      expect(uiCrop.top / 426, closeTo(exportCrop.top / 2048, 0.001));
      expect(uiCrop.width / 320, closeTo(exportCrop.width / 1536, 0.002));
    });
  });
}
