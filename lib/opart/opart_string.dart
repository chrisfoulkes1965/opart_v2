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

SettingsModel zoomOpArt = SettingsModel(
  name: 'zoomOpArt',
  settingType: SettingType.double,
  label: 'Zoom',
  tooltip: 'Zoom in and out',
  min: 0.2,
  max: 4.0,
  zoom: 100,
  defaultValue: 1.0,
  icon: const Icon(Icons.zoom_in),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel numberOfDivisions = SettingsModel(
  name: 'numberOfDivisions',
  settingType: SettingType.int,
  label: 'Number of divisions',
  tooltip: 'The number of divisions in the perimiter',
  min: 5,
  max: 100,
  randomMin: 5,
  randomMax: 50,
  defaultValue: 40,
  icon: const Icon(Icons.filter_tilt_shift),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel numberOfChords = SettingsModel(
  name: 'numberOfChords',
  settingType: SettingType.int,
  label: 'Number of chords',
  tooltip: 'The number of chords in the design',
  min: 1,
  max: 100,
  randomMin: 1,
  randomMax: 50,
  defaultValue: 20,
  icon: const Icon(Icons.filter_tilt_shift),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel skip = SettingsModel(
  name: 'skip',
  settingType: SettingType.int,
  label: 'Skip',
  tooltip: 'The number of points to skip',
  min: 0,
  max: 100,
  defaultValue: 10,
  icon: const Icon(Icons.filter_tilt_shift),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel step = SettingsModel(
  name: 'step',
  settingType: SettingType.int,
  label: 'Step',
  tooltip: 'The number of points to step',
  min: 1,
  max: 100,
  defaultValue: 1,
  icon: const Icon(Icons.filter_tilt_shift),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel spiralRatio = SettingsModel(
  settingType: SettingType.double,
  name: 'spiralRatio',
  label: 'Spiral Ratio',
  tooltip: 'The ratio of the spiral',
  min: 0.9,
  max: 1.0,
  randomMin: 0.98,
  randomMax: 1.0,
  zoom: 100,
  defaultValue: 1.0,
  icon: const Icon(Icons.arrow_circle_down),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel lineWidth = SettingsModel(
  settingType: SettingType.double,
  name: 'lineWidth',
  label: 'Line Width',
  tooltip: 'The width of the lines',
  min: 0.1,
  max: 10.0,
  zoom: 100,
  defaultValue: 3.0,
  icon: const Icon(Icons.line_weight),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel paletteType = SettingsModel(
  name: 'paletteType',
  settingType: SettingType.list,
  label: 'Palette Type',
  tooltip: 'The nature of the palette',
  defaultValue: 'random',
  icon: const Icon(Icons.colorize),
  options: <String>[
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
SettingsModel paletteList = SettingsModel(
  name: 'paletteList',
  settingType: SettingType.list,
  label: 'Palette',
  tooltip: 'Choose from a list of palettes',
  defaultValue: 'Default',
  icon: const Icon(Icons.palette),
  options: defaultPalleteNames(),
  settingCategory: SettingCategory.palette,
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
  proFeature: false,
  onChange: () {
    resetAllDefaults();
  },
  silent: true,
);

List<SettingsModel> initializeStringAttributes() {
  return [
    reDraw,
    zoomOpArt,
    numberOfDivisions,
    numberOfChords,
    skip,
    step,
    spiralRatio,
    lineWidth,
    backgroundColor,
    numberOfColors,
    paletteType,
    paletteList,
    opacity,
    randomColors,
    resetDefaults,
  ];
}

void paintString(
    Canvas canvas, Size size, int seed, double animationVariable, OpArt opArt) {
  rnd = Random(seed);

  // colour in the canvas
  canvas.drawRect(
      const Offset(0, 0) & Size(size.width, size.height),
      Paint()
        ..color = backgroundColor.value as Color
        ..style = PaintingStyle.fill);

  // double borderX = (size.width < size.height) ? 0 : (size.height - size.width)/2;
  // double borderY = (size.width > size.height) ? 0 : (size.width - size.height)/2;
  final double radius = (size.width < size.height)
      ? size.width / 2 * (zoomOpArt.value as num)
      : size.height / 2 * (zoomOpArt.value as num);
  final int chords =
      ((numberOfChords.value as int) < (numberOfDivisions.value as int))
          ? (numberOfChords.value as int)
          : (numberOfDivisions.value as int);
  int colourOrder = 0;
  Color nextColor;
  final List colorList = opArt.palette.colorList;
  double spiral = 1.0;

  for (int j = 0; j < chords; j++) {
    for (int i = 0; i < (numberOfDivisions.value as int); i++) {
      final List p0 = [
        size.width / 2 +
            spiral *
                radius *
                cos(i * 2 * pi / (numberOfDivisions.value as int)),
        size.height / 2 -
            spiral * radius * sin(i * 2 * pi / (numberOfDivisions.value as int))
      ];

      final List p1 = [
        size.width / 2 +
            spiral *
                radius *
                cos((i + 1 + j * (step.value as int) + (skip.value as int)) *
                    2 *
                    pi /
                    (numberOfDivisions.value as int)),
        size.height / 2 -
            spiral *
                radius *
                sin((i + 1 + j * (step.value as num) + (skip.value as num)) *
                    2 *
                    pi /
                    (numberOfDivisions.value as num))
      ];

      colourOrder++;
      spiral = spiral * (spiralRatio.value as num);

      nextColor = (randomColors.value as bool)
          ? colorList[rnd.nextInt(numberOfColors.value as int)]
              .withOpacity(opacity.value as double) as Color
          : colorList[colourOrder % (numberOfColors.value as int)]
              .withOpacity(opacity.value as double) as Color;

      canvas.drawLine(
          Offset(p0[0] as double, p0[1] as double),
          Offset(p1[0] as double, p1[1] as double),
          Paint()
            ..color = nextColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = lineWidth.value as double
            ..strokeCap = StrokeCap.round);
    }
  }
}
