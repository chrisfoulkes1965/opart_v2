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
  min: 20.0,
  max: 500.0,
  randomMin: 20.0,
  randomMax: 200.0,
  zoom: 100,
  defaultValue: 50.0,
  icon: const Icon(Icons.zoom_in),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel split = SettingsModel(
  name: 'split',
  settingType: SettingType.list,
  label: 'Split',
  tooltip: 'Split the hegaxom into',
  defaultValue: 'three',
  icon: const Icon(Icons.call_split),
  options: ['none', 'three', 'six'],
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel splat = SettingsModel(
  name: 'splat',
  settingType: SettingType.list,
  label: 'Split Type',
  tooltip: 'How to split the hexagons',
  defaultValue: 'center',
  icon: const Icon(Icons.settings),
  options: ['center', 'random', 'linear'],
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel threeD = SettingsModel(
  name: 'threeD',
  settingType: SettingType.bool,
  label: '3D',
  tooltip: 'Shade the colors to 3D',
  defaultValue: true,
  icon: const Icon(Icons.center_focus_strong),
  settingCategory: SettingCategory.palette,
  proFeature: false,
  silent: true,
);

SettingsModel lineWidth = SettingsModel(
  settingType: SettingType.double,
  name: 'lineWidth',
  label: 'Outline Width',
  tooltip: 'The width of the petal outline',
  min: 0.0,
  max: 3.0,
  zoom: 100,
  defaultValue: 0.0,
  icon: const Icon(Icons.line_weight),
  settingCategory: SettingCategory.tool,
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

List<SettingsModel> initializeHexagonsAttributes() {
  return [
    reDraw,
    zoomOpArt,
    split,
    splat,
    threeD,
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

void paintHexagons(
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
  // double imageWidth = canvasWidth;
  // double imageHeight = canvasHeight;

  // Work out the X and Y
  final int cellsX =
      (canvasWidth / (zoomOpArt.value as double) + 1.9999999).toInt();
  borderX = (canvasWidth - (zoomOpArt.value as num) * cellsX) / 2;

  final int cellsY =
      (canvasHeight * 2.3 / (zoomOpArt.value as num) + 1.9999999).toInt();
  borderY = (canvasHeight - (zoomOpArt.value as num) * cellsY) / 2;
  borderY = (canvasHeight - (zoomOpArt.value as num) * cellsY) / 2;

  // work out the radius from the width and the cells
  // double radius = zoomOpArt.value / 2;
  final double sideLength = (zoomOpArt.value as double) * 0.6;

  // Calculate the various constants
  const double hexagonAngle = 0.523598776; // 30 degrees in radians
  final double hexHeight = sin(hexagonAngle) * sideLength;
  final double hexRadius = cos(hexagonAngle) * sideLength;
  final double hexRectangleHeight = sideLength + 2 * hexHeight;
  final double hexRectangleWidth = 2 * hexRadius;

  int colourOrder = 0;
  Color nextColor;

  // Now make some art
  for (int i = -1; i < cellsX + 1; ++i) {
    for (int j = -1; j < cellsY + 1; ++j) {
      final double x = borderX +
          (lineWidth.value as num) / 2 +
          i * hexRectangleWidth +
          ((j % 2) * hexRadius);
      final double y = borderY + j * (sideLength + hexHeight);

      final List p1 = [x + hexRadius, y];
      final List p2 = [x + hexRectangleWidth, y + hexHeight];
      final List p3 = [x + hexRectangleWidth, y + hexHeight + sideLength];
      final List p4 = [x + hexRadius, y + hexRectangleHeight];
      final List p5 = [x, y + sideLength + hexHeight];
      final List p6 = [x, y + hexHeight];

      final List p0 = [(p1[0] + p4[0]) / 2, (p1[1] + p4[1]) / 2];

      if (splat.value == 'random') {
        p0[0] = p0[0] + (rnd.nextDouble() * hexRadius * 0.6).floor();
        p0[1] = p0[1] + (rnd.nextDouble() * hexRectangleHeight * 0.3).floor();
      } else if (splat.value == 'linear') {
        p0[0] = p0[0] + ((i - cellsX / 2) / cellsX) * hexRadius * 1.2;
        p0[1] = p0[1] + ((j - cellsY / 2) / cellsY) * hexRectangleHeight * 0.6;
      }

      switch (split.value as String) {
        case 'none':

          // Choose the next colour
          colourOrder++;
          nextColor = opArt
              .palette.colorList[colourOrder % (numberOfColors.value as int)];
          if (randomColors.value as bool) {
            nextColor = opArt
                .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
          }
          nextColor = nextColor.withOpacity(opacity.value as double);
          Color localLineColor = lineColor.value as Color;
          if (lineWidth.value == 0) {
            localLineColor = nextColor;
          }

          final Path hexagon = Path();
          hexagon.moveTo(p1[0] as double, p1[1] as double);
          hexagon.lineTo(p2[0] as double, p2[1] as double);
          hexagon.lineTo(p3[0] as double, p3[1] as double);
          hexagon.lineTo(p4[0] as double, p4[1] as double);
          hexagon.lineTo(p5[0] as double, p5[1] as double);
          hexagon.lineTo(p6[0] as double, p6[1] as double);
          hexagon.close();
          canvas.drawPath(
              hexagon,
              Paint()
                ..color = nextColor
                ..style = PaintingStyle.fill);
          canvas.drawPath(
              hexagon,
              Paint()
                ..color = localLineColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.value as double);


        case 'three':

          // R1
          // Choose the next colour
          colourOrder++;
          nextColor = opArt
              .palette.colorList[colourOrder % (numberOfColors.value as int)];
          if (randomColors.value as bool) {
            nextColor = opArt
                .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
          }
          nextColor = nextColor.withOpacity(opacity.value as double);

          if (threeD.value == true) {
            // darken this one
            final hsl = HSLColor.fromColor(nextColor);
            nextColor = hsl
                .withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0))
                .toColor();
          }

          Color localLineColor = lineColor.value as Color;
          if (lineWidth.value == 0) {
            localLineColor = nextColor;
          }

          Path rhombus = Path();
          rhombus.moveTo(p1[0] as double, p1[1] as double);
          rhombus.lineTo(p2[0] as double, p2[1] as double);
          rhombus.lineTo(p3[0] as double, p3[1] as double);
          rhombus.lineTo(p0[0] as double, p0[1] as double);
          rhombus.close();
          canvas.drawPath(
              rhombus,
              Paint()
                ..color = nextColor
                ..style = PaintingStyle.fill);
          canvas.drawPath(
              rhombus,
              Paint()
                ..color = localLineColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.value as double);

          // R2
          // Choose the next colour
          colourOrder++;
          nextColor = opArt
              .palette.colorList[colourOrder % (numberOfColors.value as int)];
          if (randomColors.value as bool) {
            nextColor = opArt
                .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
          }
          nextColor = nextColor.withOpacity(opacity.value as double);

          if (threeD.value == true) {
            // lighten this one
            final hsl = HSLColor.fromColor(nextColor);
            nextColor = hsl
                .withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0))
                .toColor();
          }

          localLineColor = lineColor.value as Color;
          if (lineWidth.value == 0) {
            localLineColor = nextColor;
          }

          // if (threeD) {
          //   // darken this one
          //
          //   var colourArray = stringToRgb(colour);
          //   for (k = 0; k < 3; ++k) {
          //     newColourArray[k] = Math.floor((colourArray[k] + 0) / 2);
          //   }
          //   colour = colourString(newColourArray);
          // }

          rhombus = Path();
          rhombus.moveTo(p3[0] as double, p3[1] as double);
          rhombus.lineTo(p4[0] as double, p4[1] as double);
          rhombus.lineTo(p5[0] as double, p5[1] as double);
          rhombus.lineTo(p0[0] as double, p0[1] as double);
          rhombus.close();
          canvas.drawPath(
              rhombus,
              Paint()
                ..color = nextColor
                ..style = PaintingStyle.fill);
          canvas.drawPath(
              rhombus,
              Paint()
                ..color = localLineColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.value as double);

          // R3
          // Choose the next colour
          colourOrder++;
          nextColor = opArt
              .palette.colorList[colourOrder % (numberOfColors.value as int)];
          if (randomColors.value as bool) {
            nextColor = opArt
                .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
          }
          nextColor = nextColor.withOpacity(opacity.value as double);
          localLineColor = lineColor.value as Color;
          if (lineWidth.value == 0) {
            localLineColor = nextColor;
          }

          // if (threeD) {
          //   // darken this one
          //
          //   var colourArray = stringToRgb(colour);
          //   for (k = 0; k < 3; ++k) {
          //     newColourArray[k] = Math.floor((colourArray[k] + 0) / 2);
          //   }
          //   colour = colourString(newColourArray);
          // }

          rhombus = Path();
          rhombus.moveTo(p5[0] as double, p5[1] as double);
          rhombus.lineTo(p6[0] as double, p6[1] as double);
          rhombus.lineTo(p1[0] as double, p1[1] as double);
          rhombus.lineTo(p0[0] as double, p0[1] as double);
          rhombus.close();
          canvas.drawPath(
              rhombus,
              Paint()
                ..color = nextColor
                ..style = PaintingStyle.fill);
          canvas.drawPath(
              rhombus,
              Paint()
                ..color = localLineColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.value as double);


        case 'six':

          // T1
          // Choose the next colour
          colourOrder++;
          nextColor = opArt
              .palette.colorList[colourOrder % (numberOfColors.value as int)];
          if (randomColors.value as bool) {
            nextColor = opArt
                .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
          }
          nextColor = nextColor.withOpacity(opacity.value as double);
          Color localLineColor = lineColor.value as Color;
          if (lineWidth.value == 0) {
            localLineColor = nextColor;
          }

          Path triangle = Path();
          triangle.moveTo(p1[0] as double, p1[1] as double);
          triangle.lineTo(p2[0] as double, p2[1] as double);
          triangle.lineTo(p0[0] as double, p0[1] as double);
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
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.value as double);

          // T2
          // Choose the next colour
          colourOrder++;
          nextColor = opArt
              .palette.colorList[colourOrder % (numberOfColors.value as int)];
          if (randomColors.value as bool) {
            nextColor = opArt
                .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
          }
          nextColor = nextColor.withOpacity(opacity.value as double);
          localLineColor = lineColor.value as Color;
          if (lineWidth.value == 0) {
            localLineColor = nextColor;
          }

          triangle = Path();
          triangle.moveTo(p2[0] as double, p2[1] as double);
          triangle.lineTo(p3[0] as double, p3[1] as double);
          triangle.lineTo(p0[0] as double, p0[1] as double);
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
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.value as double);

          // T3
          // Choose the next colour
          colourOrder++;
          nextColor = opArt
              .palette.colorList[colourOrder % (numberOfColors.value as int)];
          if (randomColors.value as bool) {
            nextColor = opArt
                .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
          }
          nextColor = nextColor.withOpacity(opacity.value as double);
          localLineColor = lineColor.value as Color;
          if (lineWidth.value == 0) {
            localLineColor = nextColor;
          }

          triangle = Path();
          triangle.moveTo(p3[0] as double, p3[1] as double);
          triangle.lineTo(p4[0] as double, p4[1] as double);
          triangle.lineTo(p0[0] as double, p0[1] as double);
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
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.value as double);

          // T4
          // Choose the next colour
          colourOrder++;
          nextColor = opArt
              .palette.colorList[colourOrder % (numberOfColors.value as int)];
          if (randomColors.value as bool) {
            nextColor = opArt
                .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
          }
          nextColor = nextColor.withOpacity(opacity.value as double);
          localLineColor = lineColor.value as Color;
          if (lineWidth.value == 0) {
            localLineColor = nextColor;
          }

          triangle = Path();
          triangle.moveTo(p4[0] as double, p4[1] as double);
          triangle.lineTo(p5[0] as double, p5[1] as double);
          triangle.lineTo(p0[0] as double, p0[1] as double);
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
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.value as double);

          // T5
          // Choose the next colour
          colourOrder++;
          nextColor = opArt
              .palette.colorList[colourOrder % (numberOfColors.value as int)];
          if (randomColors.value as bool) {
            nextColor = opArt
                .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
          }
          nextColor = nextColor.withOpacity(opacity.value as double);
          localLineColor = lineColor.value as Color;
          if (lineWidth.value == 0) {
            localLineColor = nextColor;
          }

          triangle = Path();
          triangle.moveTo(p5[0] as double, p5[1] as double);
          triangle.lineTo(p6[0] as double, p6[1] as double);
          triangle.lineTo(p0[0] as double, p0[1] as double);
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
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.value as double);

          // T6
          // Choose the next colour
          colourOrder++;
          nextColor = opArt
              .palette.colorList[colourOrder % (numberOfColors.value as int)];
          if (randomColors.value as bool) {
            nextColor = opArt
                .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
          }
          nextColor = nextColor.withOpacity(opacity.value as double);
          localLineColor = lineColor.value as Color;
          if (lineWidth.value == 0) {
            localLineColor = nextColor;
          }

          triangle = Path();
          triangle.moveTo(p6[0] as double, p6[1] as double);
          triangle.lineTo(p1[0] as double, p1[1] as double);
          triangle.lineTo(p0[0] as double, p0[1] as double);
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
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.value as double);

      }
    }
  }
}
