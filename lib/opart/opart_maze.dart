import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opart_v2/opart_icons.dart';

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
  min: 10.0,
  max: 50.0,
  zoom: 100,
  defaultValue: 20.0,
  icon: const Icon(Icons.zoom_in),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel lineHorizontal = SettingsModel(
  name: 'lineHorizontal',
  settingType: SettingType.bool,
  label: 'Horizontal',
  tooltip: 'Horizontal line',
  defaultValue: true,
  icon: const Icon(OpArtLab.lineHorizontal),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  silent: true,
);
SettingsModel lineVertical = SettingsModel(
  name: 'lineVertical',
  settingType: SettingType.bool,
  label: 'Vertical',
  tooltip: 'Vertical line',
  defaultValue: true,
  icon: const Icon(OpArtLab.lineVertical),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  silent: true,
);
SettingsModel lineDiagonalRight = SettingsModel(
  name: 'lineDiagonalRight',
  settingType: SettingType.bool,
  label: 'Diagonal Right',
  tooltip: 'Diagonal right line',
  defaultValue: true,
  icon: const Icon(OpArtLab.lineDiagonalRight),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  silent: true,
);
SettingsModel lineDiagonalLeft = SettingsModel(
  name: 'lineDiagonalLeft',
  settingType: SettingType.bool,
  label: 'Diagonal Left',
  tooltip: 'Diagonal left line',
  defaultValue: true,
  icon: const Icon(OpArtLab.lineDiagonalLeft),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  silent: true,
);
//
//
//
//
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

SettingsModel lineWidth = SettingsModel(
  name: 'lineWidth',
  settingType: SettingType.double,
  label: 'Line Width',
  tooltip: 'The width of the line',
  min: 0.0,
  max: 5.0,
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
SettingsModel paletteList = SettingsModel(
  name: 'paletteList',
  settingType: SettingType.list,
  label: 'Palette',
  tooltip: 'Choose from a list of palettes',
  defaultValue: 'Default',
  icon: const Icon(Icons.palette),
  options: defaultPalleteNames(),
  settingCategory: SettingCategory.other,
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
  onChange: () {
    resetAllDefaults();
  },
  proFeature: false,
  silent: true,
);

List<SettingsModel> initializeMazeAttributes() {
  return [
    reDraw,
    zoomOpArt,
    lineHorizontal,
    lineVertical,
    lineDiagonalLeft,
    lineDiagonalRight,
    backgroundColor,
    randomColors,
    numberOfColors,
    lineWidth,
    paletteType,
    paletteList,
    opacity,
    resetDefaults,
  ];
}

void paintMaze(
    Canvas canvas, Size size, int seed, double animationVariable, OpArt opArt) {
  rnd = Random(seed);

  if (paletteList.value != opArt.palette.paletteName) {
    opArt.selectPalette(paletteList.value as String);
  }

  // Initialise the canvas
  final double canvasWidth = size.width;
  final double canvasHeight = size.height;
  double borderX = 0;
  double borderY = 0;

  // Work out the X and Y
  final int cellsX =
      (canvasWidth / (zoomOpArt.value as num) + 1.9999999).toInt();
  borderX = (canvasWidth - (zoomOpArt.value as num) * cellsX) / 2;

  final int cellsY =
      (canvasHeight / (zoomOpArt.value as num) + 1.9999999).toInt();
  borderY = (canvasHeight - (zoomOpArt.value as num) * cellsY) / 2;
  borderY = (canvasHeight - (zoomOpArt.value as num) * cellsY) / 2;

  int colourOrder = 0;
  Color nextColor;

  // Now make some art

  // draw the square
  canvas.drawRect(
      const Offset(0, 0) & Size(canvasWidth, canvasHeight),
      Paint()
        ..color = (backgroundColor.value as Color).withOpacity(1.0)
        ..style = PaintingStyle.fill);

  final List shapesArray = [];
  if (lineHorizontal.value == true) {
    shapesArray.add('lineHorizontal');
  }
  if (lineVertical.value == true) {
    shapesArray.add('lineVertical');
  }
  if (lineDiagonalRight.value == true) {
    shapesArray.add('lineDiagonalRight');
  }
  if (lineDiagonalLeft.value == true) {
    shapesArray.add('lineDiagonalLeft');
  }

  // Now make some art
  for (int i = 0; i < cellsX; ++i) {
    for (int j = 0; j < cellsY; ++j) {
      if (shapesArray.isNotEmpty) {
        final x = borderX + i * (zoomOpArt.value as num);
        final y = borderY + j * (zoomOpArt.value as num);

        final p1 = [x, y];
        final p2 = [x + (zoomOpArt.value as num), y];
        final p3 = [x + (zoomOpArt.value as num), y + (zoomOpArt.value as num)];
        final p4 = [x, y + (zoomOpArt.value as num)];

        // Choose the next colour
        colourOrder++;
        nextColor = opArt
            .palette.colorList[colourOrder % (numberOfColors.value as int)];
        if (randomColors.value as bool) {
          nextColor =
              opArt.palette.colorList[rnd.nextInt(numberOfColors.value as int)];
        }
        nextColor = nextColor.withOpacity(opacity.value as double);

        List pA = [];
        List pB = [];

        switch (shapesArray[rnd.nextInt(shapesArray.length)] as String) {
          case 'lineDiagonalRight':
            pA = p1;
            pB = p3;
          case 'lineDiagonalLeft':
            pA = p2;
            pB = p4;
          case 'lineHorizontal':
            pA = p1;
            pB = p2;
          case 'lineVertical':
            pA = p2;
            pB = p3;
        }

        // draw the line
        canvas.drawLine(
            Offset(pA[0] as double, pA[1] as double),
            Offset(pB[0] as double, pB[1] as double),
            Paint()
              ..color = nextColor
              ..style = PaintingStyle.stroke
              ..strokeWidth =
                  (lineWidth.value as double) * (zoomOpArt.value as num) / 10
              ..strokeCap = StrokeCap.round);
      }
    }
  }
}
