import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:opart_v2/app_state.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/model_palette.dart';
import 'package:opart_v2/model_settings.dart';

List<String> list = [];

SettingsModel reDraw = SettingsModel(
  name: 'reDraw',
  settingType: SettingType.button,
  label: 'Redraw',
  tooltip: 'Re-draw the picture with a different random seed',
  defaultValue: false,
  icon: const Icon(Icons.refresh),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  onChange: () {
    seed = DateTime.now().millisecond;
  },
  silent: true,
);

SettingsModel minimumDepth = SettingsModel(
  settingType: SettingType.int,
  name: 'minimumDepth',
  label: 'Minimum Depth',
  tooltip: 'The minimum recursion depth',
  min: 0,
  max: 10,
  zoom: 100,
  defaultValue: 6,
  icon: const Icon(Icons.line_weight),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel maximumDepth = SettingsModel(
  settingType: SettingType.int,
  name: 'maximumDepth',
  label: 'Maximum Depth',
  tooltip: 'The maximum recursion depth',
  min: 0,
  max: 20,
  zoom: 100,
  defaultValue: 10,
  icon: const Icon(Icons.line_weight),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel density = SettingsModel(
  name: 'density',
  settingType: SettingType.double,
  label: 'Density',
  tooltip: 'The recursion density',
  min: 0.0,
  max: 1.0,
  zoom: 100,
  defaultValue: 0.55,
  icon: const Icon(Icons.remove_red_eye),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel ratio = SettingsModel(
  name: 'ratio',
  settingType: SettingType.double,
  label: 'Ratio',
  tooltip: 'The split ratio of each square',
  min: 0.0,
  max: 1.0,
  randomMin: 0.45,
  randomMax: 0.55,
  zoom: 100,
  defaultValue: 0.5,
  icon: const Icon(Icons.remove_red_eye),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel randomiseRatio = SettingsModel(
  name: 'randomiseRatio',
  settingType: SettingType.bool,
  label: 'Randomise Ratio',
  tooltip: 'Randomise the split ratio',
  defaultValue: false,
  icon: const Icon(Icons.track_changes),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  silent: true,
);

SettingsModel lineWidth = SettingsModel(
  settingType: SettingType.double,
  name: 'lineWidth',
  label: 'Outline Width',
  tooltip: 'The width of the petal outline',
  min: 0.0,
  max: 10.0,
  zoom: 100,
  defaultValue: 3.0,
  icon: const Icon(Icons.line_weight),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);
//
// SettingsModel randomColors = SettingsModel(
//   name: 'randomColors',
//   settingType: SettingType.bool,
//   label: 'Random Colors',
//   tooltip: 'randomize the colours',
//   defaultValue: true,
//   icon: const Icon(Icons.gamepad),
//   settingCategory: SettingCategory.tool,
//   proFeature: false,
//   silent: true,
// );

SettingsModel paletteType = SettingsModel(
  name: 'paletteType',
  settingType: SettingType.list,
  label: 'Palette Type',
  tooltip: 'The nature of the palette',
  defaultValue: 'random',
  icon: const Icon(Icons.colorize),
  options: [
    'random',
    'blended random',
    'linear random',
    'linear complementary'
  ],
  settingCategory: SettingCategory.palette,
  onChange: () {
    generatePalette();
  },
  proFeature: false,
);

SettingsModel resetDefaults = SettingsModel(
  name: 'resetDefaults',
  settingType: SettingType.button,
  label: 'Reset Defaults',
  tooltip: 'Reset all settings to defaults',
  defaultValue: false,
  icon: const Icon(Icons.low_priority),
  settingCategory: SettingCategory.tool,
  onChange: () {},
  silent: true,
  proFeature: false,
);

List<SettingsModel> initializeTrianglesAttributes() {
  return [
    reDraw,
    minimumDepth,
    maximumDepth,
    density,
    ratio,
    randomiseRatio,
    lineColor,
    lineWidth,
    randomColors,
    numberOfColors,
    paletteType,
    paletteList,
    opacity,
    resetDefaults,
  ];
}

void paintTriangles(
    Canvas canvas, Size size, int seed, double animationVariable, OpArt opArt) {
  rnd = Random(seed);

  if (paletteList.value != opArt.palette.paletteName) {
    opArt.selectPalette(paletteList.value as String);
  }

  // Initialise the canvas
  final double canvasWidth = size.width;
  final double canvasHeight = size.height;

  final double imageSize =
      (canvasHeight > canvasWidth) ? canvasHeight : canvasWidth;

  // Now make some art
  final List p1 = [
    (canvasWidth - imageSize) / 2,
    (canvasHeight - imageSize) / 2
  ];
  final List p2 = [imageSize, (canvasHeight - imageSize) / 2];
  final List p3 = [imageSize, imageSize];
  final List p4 = [(canvasWidth - imageSize) / 2, imageSize];

  drawTriangle(
      canvas,
      opArt.palette.colorList,
      p1,
      p2,
      p3,
      0,
      minimumDepth.value.toInt() as int,
      maximumDepth.value.toInt() as int,
      ratio.value as double,
      density.value as double,
      randomiseRatio.value as bool,
      0,
      lineColor.value as Color,
      lineWidth.value as double);

  drawTriangle(
      canvas,
      opArt.palette.colorList,
      p1,
      p4,
      p3,
      0,
      minimumDepth.value.toInt() as int,
      maximumDepth.value.toInt() as int,
      ratio.value as double,
      density.value as double,
      randomiseRatio.value as bool,
      0,
      lineColor.value as Color,
      lineWidth.value as double);
}

void drawTriangle(
    Canvas canvas,
    List colorList,
    List p0,
    List p1,
    List p2,
    int recursionDepth,
    int minimumDepth,
    int maximumDepth,
    double ratio,
    double density,
    bool randomiseRatio,
    int colourOrder,
    Color lineColor,
    double lineWidth) {
  if (recursionDepth < minimumDepth ||
      (recursionDepth < maximumDepth && rnd.nextDouble() < density)) {
    // split
    // work out the longest length
    final double l0 = ((p2[0] as double) - (p1[0] as double)) *
            ((p2[0] as double) - (p1[0] as double)) +
        ((p2[1] as double) - (p1[1] as double)) *
            ((p2[1] as double) - (p1[1] as double));
    final double l1 = ((p2[0] as double) - (p0[0] as double)) *
            ((p2[0] as double) - (p0[0] as double)) +
        ((p2[1] as double) - (p0[1] as double)) *
            ((p2[1] as double) - (p0[1] as double));
    final double l2 = ((p0[0] as double) - (p1[0] as double)) *
            ((p0[0] as double) - (p1[0] as double)) +
        ((p0[1] as double) - (p1[1] as double)) *
            ((p0[1] as double) - (p1[1] as double));

    final int splitDirection = (l2 > l0 && l2 > l1)
        ? 2
        : (l1 > l0)
            ? 1
            : 0;

    var localRatio = ratio;
    if (randomiseRatio) {
      localRatio = ratio * (rnd.nextDouble() / 10 + 0.95);
    }

    switch (splitDirection) {
      case 0:
        final List pN = [
          p1[0] * localRatio + p2[0] * (1 - localRatio),
          p1[1] * localRatio + p2[1] * (1 - localRatio)
        ];

        drawTriangle(
            canvas,
            colorList,
            p0,
            p1,
            pN,
            recursionDepth + 1,
            minimumDepth,
            maximumDepth,
            ratio,
            density,
            randomiseRatio,
            colourOrder + 1,
            lineColor,
            lineWidth);

        drawTriangle(
            canvas,
            colorList,
            p0,
            p2,
            pN,
            recursionDepth + 1,
            minimumDepth,
            maximumDepth,
            ratio,
            density,
            randomiseRatio,
            colourOrder + 2,
            lineColor,
            lineWidth);


      case 1:
        final List pN = [
          p0[0] * localRatio + p2[0] * (1 - localRatio),
          p0[1] * localRatio + p2[1] * (1 - localRatio)
        ];

        drawTriangle(
            canvas,
            colorList,
            p1,
            p0,
            pN,
            recursionDepth + 1,
            minimumDepth,
            maximumDepth,
            ratio,
            density,
            randomiseRatio,
            colourOrder + 1,
            lineColor,
            lineWidth);

        drawTriangle(
            canvas,
            colorList,
            p1,
            p2,
            pN,
            recursionDepth + 1,
            minimumDepth,
            maximumDepth,
            ratio,
            density,
            randomiseRatio,
            colourOrder + 2,
            lineColor,
            lineWidth);


      case 2:
        final List pN = [
          p0[0] * localRatio + p1[0] * (1 - localRatio),
          p0[1] * localRatio + p1[1] * (1 - localRatio)
        ];

        drawTriangle(
            canvas,
            colorList,
            p2,
            p0,
            pN,
            recursionDepth + 1,
            minimumDepth,
            maximumDepth,
            ratio,
            density,
            randomiseRatio,
            colourOrder + 1,
            lineColor,
            lineWidth);

        drawTriangle(
            canvas,
            colorList,
            p2,
            p1,
            pN,
            recursionDepth + 1,
            minimumDepth,
            maximumDepth,
            ratio,
            density,
            randomiseRatio,
            colourOrder + 2,
            lineColor,
            lineWidth);

    }
  } else {
    // Choose the next colour
    Color nextColor;
    colourOrder++;
    nextColor = colorList[colourOrder % (numberOfColors.value as int)] as Color;
    if (randomColors.value as bool) {
      nextColor = colorList[rnd.nextInt(numberOfColors.value as int)] as Color;
    }
    nextColor = nextColor.withOpacity(opacity.value as double);
    Color localLineColor = lineColor;
    if (lineWidth == 0) {
      localLineColor = nextColor;
    }

    final Path triangle = Path();
    triangle.moveTo(p0[0] as double, p0[1] as double);
    triangle.lineTo(p1[0] as double, p1[1] as double);
    triangle.lineTo(p2[0] as double, p2[1] as double);
    triangle.close();
    canvas.drawPath(
        triangle,
        Paint()
          ..color = nextColor
          ..style = PaintingStyle.fill);
    canvas.drawPath(
        triangle,
        Paint()
          ..color = localLineColor
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineWidth);
  }
}
