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
  min: 10.0,
  max: 100.0,
  zoom: 100,
  defaultValue: 40.0,
  icon: const Icon(Icons.zoom_in),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel gradientTypeX0 = SettingsModel(
  name: 'gradientTypeX0',
  settingType: SettingType.list,
  label: 'gradientTypeX0',
  tooltip: 'gradientTypeX0',
  defaultValue: 'linear',
  icon: const Icon(Icons.settings),
  options: ['linear', 'cycle:0-1', 'cycle:0.5-0.5', 'fixed'],
  settingCategory: SettingCategory.tool,
  proFeature: false,
);
SettingsModel gradientTypeX1 = SettingsModel(
  name: 'gradientTypeX1',
  settingType: SettingType.list,
  label: 'gradientTypeX1',
  tooltip: 'gradientTypeX1',
  defaultValue: 'linear',
  icon: const Icon(Icons.settings),
  options: ['linear', 'cycle:0-1', 'cycle:0.5-0.5', 'fixed'],
  settingCategory: SettingCategory.tool,
  proFeature: false,
);
SettingsModel gradientTypeY0 = SettingsModel(
  name: 'gradientTypeY0',
  settingType: SettingType.list,
  label: 'gradientTypeY0',
  tooltip: 'gradientTypeY0',
  defaultValue: 'linear',
  icon: const Icon(Icons.settings),
  options: ['linear', 'cycle:0-1', 'cycle:0.5-0.5', 'fixed'],
  settingCategory: SettingCategory.tool,
  proFeature: false,
);
SettingsModel gradientTypeY1 = SettingsModel(
  name: 'gradientTypeY1',
  settingType: SettingType.list,
  label: 'gradientTypeY1',
  tooltip: 'gradientTypeY1',
  defaultValue: 'linear',
  icon: const Icon(Icons.settings),
  options: ['linear', 'cycle:0-1', 'cycle:0.5-0.5', 'fixed'],
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

//
//
// SettingsModel randomColors = SettingsModel(
//   name: 'randomColors',
//   settingType: SettingType.bool,
//   label: 'Random Colors',
//   tooltip: 'randomize the colours',
//   defaultValue: false,
//   icon: const Icon(Icons.gamepad),
//   settingCategory: SettingCategory.tool,
//   proFeature: false,
//   silent: true,
//
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
SettingsModel paletteList = SettingsModel(
  name: 'paletteList',
  settingType: SettingType.list,
  label: 'Palette',
  tooltip: 'Choose from a list of palettes',
  defaultValue: 'Black and White',
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

List<SettingsModel> initializeRileyAttributes() {
  return [
    reDraw,
    zoomOpArt,
    gradientTypeX0,
    gradientTypeX1,
    gradientTypeY0,
    gradientTypeY1,
    randomColors,
    numberOfColors,
    paletteType,
    paletteList,
    opacity,
    resetDefaults,
  ];
}

void paintRiley(
    Canvas canvas, Size size, int seed, double animationVariable, OpArt opArt) {
  rnd = Random(seed);

  // if (paletteList.value != opArt.palette.paletteName){
  //   opArt.selectPalette(paletteList.stringValue);
  // }

  // Initialise the canvas
  final double canvasWidth = size.width;
  final double canvasHeight = size.height;
  double borderX = 0;
  double borderY = 0;

  // Work out the X and Y
  final double sideLength = zoomOpArt.doubleValue;

  final int cellsX = (canvasWidth / (zoomOpArt.numValue) + 1.9999999).toInt();
  borderX = (canvasWidth - (zoomOpArt.numValue) * cellsX) / 2;

  final int cellsY = (canvasHeight / (zoomOpArt.numValue) + 1.9999999).toInt();
  borderY = (canvasHeight - (zoomOpArt.numValue) * cellsY) / 2;
  borderY = (canvasHeight - (zoomOpArt.numValue) * cellsY) / 2;

  int colourOrder = 0;
  Color nextColor;

  // Now make some art
  final double cellSizeX = sideLength;
  final double cellSizeY = sideLength;

  double gradientH;
  double gradientV;

  for (int i = 0; i < cellsX; ++i) {
    for (int j = 0; j < cellsY; ++j) {
      double h0 = 0;
      double hN = 0;
      double v0 = 0;
      double vN = 0;

      switch (gradientTypeX0.stringValue) {
        case 'linear':
          // Linear progression
          h0 = i / (cellsX - 1);

        case 'cycle:0-1':
          // Sin progression
          h0 = sin(pi * i / (cellsX - 1));

        case 'cycle:0.5-0.5':
          // cos progression
          h0 = 0.5 + 0.5 * cos(pi * 2 * i / (cellsX - 1));

        case 'fixed':
          h0 = 0.5;
      }

      switch (gradientTypeX1.stringValue) {
        case 'linear':
          // Linear progression
          hN = i / (cellsX - 1);

        case 'cycle:0-1':
          // Sin progression
          hN = sin(pi * i / (cellsX - 1));

        case 'cycle:0.5-0.5':
          // cos progression
          hN = 0.5 + 0.5 * cos(pi * 2 * i / (cellsX - 1));

        case 'fixed':
          hN = 0.5;
      }

      switch (gradientTypeY0.stringValue) {
        case 'linear':
          // Linear progression
          v0 = j / (cellsY - 1);

        case 'cycle:0-1':
          // Sin progression
          v0 = sin(pi * j / (cellsY - 1));

        case 'cycle:0.5-0.5':
          // Cos progression
          v0 = 0.5 + 0.5 * cos(pi * 2 * j / (cellsY - 1));

        case 'fixed':
          v0 = 0.5;
      }

      switch (gradientTypeY1.stringValue) {
        case 'linear':
          // Linear progression
          vN = j / (cellsY - 1);

        case 'cycle:0-1':
          // Sin progression
          vN = sin(pi * j / (cellsY - 1));

        case 'cycle:0.5-0.5':
          // Cos progression
          vN = 0.5 + 0.5 * cos(pi * 2 * j / (cellsY - 1));

        case 'fixed':
          vN = 0.5;
      }

      // If the line is vertical then it is a special case...
      if (h0 == hN) {
        gradientH = (vN - v0) / cellsX;
        gradientV = 999999999;
      } else {
        gradientH = (vN - v0) / cellsX;
        gradientV = cellsY / (hN - h0);
      }

      //9 points
      final List<double> pA = [
        borderX + cellSizeX * i,
        borderY + cellSizeY * j
      ];

      final List<double> pB = [
        borderX + cellSizeX * (i + h0 + (j / cellsY) * (hN - h0)),
        borderY + cellSizeY * j
      ];

      final List<double> pC = [
        borderX + cellSizeX * (i + 1),
        borderY + cellSizeY * j
      ];

      final List<double> pD = [
        borderX + cellSizeX * (i + 1),
        borderY + cellSizeY * (j + v0 + ((i + 1) / cellsX) * (vN - v0))
      ];

      final List<double> pE = [
        borderX + cellSizeX * (i + 1),
        borderY + cellSizeY * (j + 1)
      ];

      final List<double> pF = [
        borderX + cellSizeX * (i + h0 + ((j + 1) / cellsY) * (hN - h0)),
        borderY + cellSizeY * (j + 1)
      ];

      final List<double> pG = [
        borderX + cellSizeX * i,
        borderY + cellSizeY * (j + 1)
      ];

      final List<double> pH = [
        borderX + cellSizeX * i,
        borderY + cellSizeY * (j + v0 + (i / cellsX) * (vN - v0))
      ];

      final double X =
          (j + v0 + (i + h0) * gradientV) / (gradientV - gradientH);
      final List<double> pO = [
        borderX + cellSizeX * X,
        borderY + cellSizeY * (j + v0 + gradientH * X)
      ];

      // four quads...

      colourOrder++;
      nextColor = (randomColors.boolValue)
          ? opArt.palette.colorList[rnd.nextInt(numberOfColors.intValue)]
              .withValues(alpha: opacity.doubleValue)
          : opArt.palette.colorList[colourOrder % (numberOfColors.intValue)]
              .withValues(alpha: opacity.doubleValue);
      fillQuad(canvas, pA, pB, pO, pH, nextColor);

      colourOrder++;
      nextColor = (randomColors.boolValue)
          ? opArt.palette.colorList[rnd.nextInt(numberOfColors.intValue)]
              .withValues(alpha: opacity.doubleValue)
          : opArt.palette.colorList[colourOrder % (numberOfColors.intValue)]
              .withValues(alpha: opacity.doubleValue);
      fillQuad(canvas, pB, pC, pD, pO, nextColor);

      colourOrder++;
      nextColor = (randomColors.boolValue)
          ? opArt.palette.colorList[rnd.nextInt(numberOfColors.intValue)]
              .withValues(alpha: opacity.doubleValue)
          : opArt.palette.colorList[colourOrder % (numberOfColors.intValue)]
              .withValues(alpha: opacity.doubleValue);
      fillQuad(canvas, pO, pD, pE, pF, nextColor);

      colourOrder++;
      nextColor = (randomColors.boolValue)
          ? opArt.palette.colorList[rnd.nextInt(numberOfColors.intValue)]
              .withValues(alpha: opacity.doubleValue)
          : opArt.palette.colorList[colourOrder % (numberOfColors.intValue)]
              .withValues(alpha: opacity.doubleValue);
      fillQuad(canvas, pH, pO, pF, pG, nextColor);
    }
  }
}

void fillQuad(Canvas canvas, List<double> p1, List<double> p2, List<double> p3,
    List<double> p4, Color nextColor) {
  final Path quad = Path();
  quad.moveTo(p1[0], p1[1]);
  quad.lineTo(p2[0], p2[1]);
  quad.lineTo(p3[0], p3[1]);
  quad.lineTo(p4[0], p4[1]);
  quad.close();

  canvas.drawPath(
      quad,
      Paint()
        ..color = nextColor
        ..style = PaintingStyle.fill);

  canvas.drawPath(
      quad,
      Paint()
        ..color = nextColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.01);
}
