import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:opart_v2/app_state.dart';
import 'package:opart_v2/database_helper.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/model_palette.dart';
import 'package:opart_v2/model_settings.dart';
import 'package:opart_v2/op_art_catalog.dart';

const Size _warmUpPaintSize = Size(120, 120);

Future<void> warmUpOpArtLab(BuildContext context) async {
  await DatabaseHelper.instance.getUserDb();
  if (!context.mounted) {
    return;
  }

  for (final entry in kOpArtCatalog) {
    if (!context.mounted) {
      return;
    }
    await precacheImage(AssetImage(entry.image), context);
    await Future<void>.delayed(Duration.zero);
  }

  defaultPalettes.length;

  for (final type in OpArtType.values) {
    final opArt = OpArt(opArtType: type);
    checkNumberOfColors();
    final recorder = ui.PictureRecorder();
    opArt.paint(Canvas(recorder), _warmUpPaintSize, seed, 1);
    recorder.endRecording().dispose();
    await Future<void>.delayed(Duration.zero);
  }
}
