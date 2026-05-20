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

SettingsModel numberOfPoints = SettingsModel(
  settingType: SettingType.int,
  name: 'numberOfPoints',
  label: 'Number of Points',
  tooltip: 'The number of points',
  min: 1,
  max: 5000,
  randomMin: 1,
  randomMax: 2000,
  zoom: 100,
  defaultValue: 1000,
  icon: const Icon(Icons.line_weight),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel numberToLink = SettingsModel(
  settingType: SettingType.int,
  name: 'numberToLink',
  label: 'Number to Link',
  tooltip: 'The number of points to link',
  min: 1,
  max: 50,
  zoom: 100,
  defaultValue: 15,
  icon: const Icon(Icons.line_weight),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel skipPoints = SettingsModel(
  settingType: SettingType.int,
  name: 'skipPoints',
  label: 'Skip Points',
  tooltip: 'The number of points to skip',
  min: 0,
  max: 10,
  zoom: 100,
  defaultValue: 0,
  icon: const Icon(Icons.line_weight),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel lines = SettingsModel(
  name: 'lines',
  settingType: SettingType.bool,
  label: 'Lines',
  tooltip: 'draw lines between each point',
  defaultValue: true,
  icon: const Icon(Icons.timeline),
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
  defaultValue: 1.0,
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
    'linear complementary',
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

List<SettingsModel> initializeNeighbourAttributes() {
  return [
    reDraw,
    numberOfPoints,
    numberToLink,
    skipPoints,
    lines,

    backgroundColor,
    lineColor,
    lineWidth,
    // randomColors,
    numberOfColors,
    paletteType,
    paletteList,
    opacity,
    resetDefaults,
  ];
}

void paintNeighbour(
  Canvas canvas,
  Size size,
  int seed,
  double animationVariable,
  OpArt opArt,
) {
  rnd = Random(seed);

  if (paletteList.value != opArt.palette.paletteName) {
    opArt.selectPalette(paletteList.stringValue);
  }

  // Initialise the canvas
  final double canvasWidth = size.width;
  final double canvasHeight = size.height;

  // draw the square
  canvas.drawRect(
    Offset.zero & Size(canvasWidth, canvasHeight),
    Paint()
      ..color = (backgroundColor.colorValue).withValues(alpha: 1.0)
      ..style = PaintingStyle.fill,
  );

  // Now make some art
  drawNeighbours(
    canvas,
    opArt.palette.colorList,
    canvasWidth,
    canvasHeight,
    lineWidth.doubleValue,
    numberOfPoints.intValue,
    numberToLink.intValue,
    skipPoints.intValue,
  );
}

Future<void> drawNeighbours(
  Canvas canvas,
  List<Color> colorList,
  double canvasWidth,
  double canvasHeight,
  double lineWidth,
  int numberOfPoints,
  int numberToLink,
  int skipPoints,
) async {
  int colourOrder = 0;

  final List<List<double>> points = [];
  for (int i = 0; i < numberOfPoints; i++) {
    points.add([
      canvasWidth * rnd.nextDouble(),
      canvasHeight * rnd.nextDouble(),
    ]);
  }

  // process each point
  for (final point in points) {
    final List<List<double>> sortedPoints = List<List<double>>.from(points);
    sortedPoints.sort(
      (point1, point2) =>
          ((pow(point1[0] - point[0], 2) + pow(point1[1] - point[1], 2)) -
                  (pow(point2[0] - point[0], 2) + pow(point2[1] - point[1], 2)))
              .toInt(),
    );

    for (int j = 1 + skipPoints; j < numberToLink + skipPoints; j++) {
      // print('$countPoints - $j');

      // Choose the next colour
      colourOrder++;
      Color nextColor = colorList[colourOrder % (numberOfColors.intValue)];
      if (randomColors.boolValue) {
        nextColor = colorList[rnd.nextInt(numberOfColors.intValue)];
      }
      nextColor = nextColor.withValues(alpha: opacity.doubleValue);

      canvas.drawLine(
        Offset(point[0], point[1]),
        Offset(sortedPoints[j][0], sortedPoints[j][1]),
        Paint()
          ..color = nextColor
          // ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineWidth
          // ..strokeWidth = 1
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}
