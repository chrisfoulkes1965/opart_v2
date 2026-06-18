import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/opart/opart_flow.dart' as flow;
import 'package:opart_v2/print/models/opart_recipe.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Flow paints with default settings', () {
    final opArt = OpArt(opArtType: OpArtType.Flow);
    final recorder = ui.PictureRecorder();
    opArt.paint(Canvas(recorder), const Size(411, 923), 42, 1);
    recorder.endRecording().dispose();
  });

  test('Flow paints when frequency is zero', () {
    final opArt = OpArt(opArtType: OpArtType.Flow);
    flow.frequency.value = 0.0;
    final recorder = ui.PictureRecorder();
    opArt.paint(Canvas(recorder), const Size(411, 923), 42, 1);
    recorder.endRecording().dispose();
    flow.frequency.setDefault();
  });

  test('Flow paints from default recipe', () {
    final recipe = OpArtRecipe.defaultForType(OpArtType.Flow);
    final opArt = OpArtRecipe.toOpArt(recipe);
    final recorder = ui.PictureRecorder();
    opArt.paint(
      Canvas(recorder),
      const Size(411, 923),
      OpArtRecipe.seedFrom(recipe),
      OpArtRecipe.animationValueFrom(recipe),
    );
    recorder.endRecording().dispose();
  });
}
