import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/print/models/opart_recipe.dart';
import 'package:opart_v2/print/models/print_placement.dart';
import 'package:opart_v2/print/models/print_spec.dart';

class PrintExportService {
  const PrintExportService();

  Future<Uint8List> renderToPng({
    required OpArt opArt,
    required int seed,
    required double animationValue,
    required PrintSpec spec,
    PrintFitMode fit = PrintFitMode.cover,
    PrintPlacement placement = PrintPlacement.initial,
  }) async {
    final width = spec.widthPx;
    final height = spec.heightPx;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = const Color(0xFFFFFFFF),
    );

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
    _paintOpArtInRect(
      canvas: canvas,
      targetWidth: width.toDouble(),
      targetHeight: height.toDouble(),
      opArt: opArt,
      seed: seed,
      animationValue: animationValue,
      fit: fit,
      placement: placement,
    );
    canvas.restore();

    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(width, height);
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

  void _paintOpArtInRect({
    required Canvas canvas,
    required double targetWidth,
    required double targetHeight,
    required OpArt opArt,
    required int seed,
    required double animationValue,
    required PrintFitMode fit,
    required PrintPlacement placement,
  }) {
    final baselineSide = fit == PrintFitMode.cover
        ? math.max(targetWidth, targetHeight)
        : math.min(targetWidth, targetHeight);

    final paintedSide = baselineSide * placement.scale.clamp(0.5, 4.0);

    final maxPanX = math.max(0, (paintedSide - targetWidth) / 2);
    final maxPanY = math.max(0, (paintedSide - targetHeight) / 2);

    final panX = placement.offsetX.clamp(-1.0, 1.0) * maxPanX;
    final panY = placement.offsetY.clamp(-1.0, 1.0) * maxPanY;

    final offsetX = (targetWidth - paintedSide) / 2 + panX;
    final offsetY = (targetHeight - paintedSide) / 2 + panY;

    canvas.translate(offsetX, offsetY);
    opArt.paint(canvas, Size(paintedSide, paintedSide), seed, animationValue);
  }

  Future<Uint8List> renderRecipeToPng({
    required Map<String, dynamic> recipe,
    required PrintSpec spec,
    PrintFitMode fit = PrintFitMode.cover,
    PrintPlacement placement = PrintPlacement.initial,
  }) {
    final opArt = OpArtRecipe.toOpArt(recipe);
    return renderToPng(
      opArt: opArt,
      seed: OpArtRecipe.seedFrom(recipe),
      animationValue: OpArtRecipe.animationValueFrom(recipe),
      spec: spec,
      fit: fit,
      placement: placement,
    );
  }
}
