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

SettingsModel groups = SettingsModel(
  name: 'groups',
  settingType: SettingType.int,
  label: 'Groups',
  tooltip: 'Minimum number of groups',
  min: 1,
  max: 25,
  randomMin: 1,
  randomMax: 10,
  zoom: 100,
  defaultValue: 5,
  icon: const Icon(Icons.zoom_in),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel border = SettingsModel(
  name: 'border',
  settingType: SettingType.double,
  label: 'Border',
  tooltip: 'The border width',
  min: 0.0,
  max: 100.0,
  randomMin: 0.0,
  randomMax: 10.0,
  zoom: 100,
  defaultValue: 25.0,
  icon: const Icon(Icons.border_style),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel numberOfPipes = SettingsModel(
  name: 'numberOfPipes',
  settingType: SettingType.int,
  label: 'Number Of Pipes',
  tooltip: 'The number of pipes',
  min: 1,
  max: 50,
  randomMin: 1,
  randomMax: 15,
  defaultValue: 32,
  icon: const Icon(Icons.clear_all),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel ratio = SettingsModel(
  name: 'ratio',
  settingType: SettingType.double,
  label: 'Ratio',
  tooltip: 'The ratio of left and right',
  min: 0.0,
  max: 1.0,
  randomMin: 0.1,
  randomMax: 1.0,
  zoom: 100,
  defaultValue: 1.0,
  icon: const Icon(Icons.pie_chart),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel oneDirection = SettingsModel(
  name: 'oneDirection',
  settingType: SettingType.bool,
  label: 'One Direction',
  tooltip: 'Only bulge in one direction',
  defaultValue: true,
  icon: const Icon(Icons.arrow_upward),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  silent: true,
);

SettingsModel shape = SettingsModel(
  name: 'shape',
  settingType: SettingType.list,
  label: 'Shape',
  tooltip: 'The shape in the cell',
  defaultValue: 'circle',
  icon: const Icon(Icons.settings),
  options: ['circle', 'triangle', 'line', 'square'],
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel pointiness = SettingsModel(
  name: 'pointiness',
  settingType: SettingType.double,
  label: 'Pointiness',
  tooltip: 'the pointiness of the triangle',
  min: 0.0,
  max: 2.0,
  zoom: 200,
  defaultValue: 1.1,
  icon: const Icon(Icons.change_history_sharp),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel resetColors = SettingsModel(
  name: 'resetColors',
  settingType: SettingType.bool,
  label: 'Reset Colors',
  tooltip: 'Reset the colours for each cell',
  defaultValue: true,
  randomTrue: 0.9,
  icon: const Icon(Icons.gamepad),
  settingCategory: SettingCategory.tool,
  proFeature: true,
  silent: true,
);

SettingsModel aspectRatio = SettingsModel(
  name: 'aspectRatio',
  settingType: SettingType.list,
  label: 'Aspect Ratio',
  tooltip: 'The aspect ration of the image',
  defaultValue: 'full screen',
  icon: const Icon(Icons.aspect_ratio),
  options: ['full screen', '1:1', '4:3'],
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

List<SettingsModel> initializeDiagonalAttributes() {
  return [
    reDraw,
    groups,
    border,
    numberOfPipes,
    ratio,
    shape,
    pointiness,
    oneDirection,
    aspectRatio,
    resetColors,
    backgroundColor,
    randomColors,
    numberOfColors,
    paletteType,
    paletteList,
    opacity,
    resetDefaults,
  ];
}

void paintDiagonal(
    Canvas canvas, Size size, int seed, double animationVariable, OpArt opArt) {
  canvas.drawRect(
      const Offset(0, 0) & Size(size.width, size.height),
      Paint()
        ..color = Colors.black.withOpacity(1.0)
        ..style = PaintingStyle.fill);

  rnd = Random(seed);
  // print('seed: $seed');

  if (paletteList.value != opArt.palette.paletteName) {
    opArt.selectPalette(paletteList.value as String);
  }

  // Initialise the canvas
  double canvasWidth = size.width;
  double canvasHeight = size.height;
  print('canvasWidth: $canvasWidth');
  print('canvasHeight: $canvasHeight');

  //double sideLength = zoomOpArt.value as double;
  // print("sideLength: "+sideLength.toString());

  print('aspectRatio: ${aspectRatio.value}');

  switch (aspectRatio.value.toString()) {
    case '1:1':
      if (canvasWidth > canvasHeight) {
        canvasWidth = canvasHeight;
      } else {
        canvasHeight = canvasWidth;
      }

    case '4:3':
      if (canvasWidth / canvasHeight > 4 / 3) {
        canvasWidth = canvasHeight * 4 / 3;
      } else if (canvasHeight / canvasWidth > 4 / 3) {
        canvasHeight = canvasWidth * 4 / 3;
      } else if (canvasWidth > canvasHeight) {
        canvasHeight = canvasWidth * 3 / 4;
      } else {
        canvasWidth = canvasHeight * 3 / 4;
      }
  }

  final double marginX = (size.width - canvasWidth) / 2;
  final double marginY = (size.height - canvasHeight) / 2;
  print('marginX: $marginX');
  print('marginY: $marginY');

  final double minHeightWidth =
      (canvasWidth < canvasHeight) ? canvasWidth : canvasHeight;
  print('minHeightWidth: $minHeightWidth');

  int numberOfGroups = groups.value as int;
  print("numberOfGroups: $numberOfGroups");

  double borderWidth = border.value as double;
  if (borderWidth > minHeightWidth / 2) {
    borderWidth = minHeightWidth / 2;
    numberOfGroups = 0;
  }
  print('borderWidth: $borderWidth');
  print("numberOfGroups: $numberOfGroups");

  // Work out the X and Y
  int cellsX;
  int cellsY;
  double borderX;
  double borderY;
  double sideLength;

  if (canvasWidth <= canvasHeight) {
    cellsX = numberOfGroups;
    borderX = borderWidth;
    sideLength = (canvasWidth - borderWidth * 2) / numberOfGroups;
    cellsY = ((canvasHeight - borderWidth * 2) / sideLength).floor();
    borderY = (canvasHeight - sideLength * cellsY) / 2;
  } else {
    cellsY = numberOfGroups;
    borderY = borderWidth;
    sideLength = (canvasHeight - borderWidth * 2) / numberOfGroups;
    cellsX = ((canvasWidth - borderWidth * 2) / sideLength).floor();
    borderX = (canvasWidth - borderWidth * 2 - sideLength * cellsX) / 2;
  }

  print("sideLength: $sideLength");
  print("cellsX: $cellsX");
  print("cellsY: $cellsY");
  print("borderX: $borderX");
  print("borderY: $borderY");

  // Now make some art
  drawDiagonal(
      canvas,
      canvasWidth,
      canvasHeight,
      cellsX,
      cellsY,
      marginX,
      marginY,
      borderX,
      borderY,
      sideLength,
      opArt.palette.colorList,
      backgroundColor.value as Color,
      oneDirection.value == true,
      numberOfPipes.value as int,
      shape.value as String,
      pointiness.value as double);
}

void drawDiagonal(
  Canvas canvas,
  double canvasWidth,
  double canvasHeight,
  int cellsX,
  int cellsY,
  double marginX,
  double marginY,
  double borderX,
  double borderY,
  double sideLength,
  List colorList,
  Color backgroundColor,
  bool oneDirection,
  int pipes,
  String shape,
  double pointiness,
) {
  bool parity = false;
  List centre1 = [];
  List centre2 = [];
  double startAngle = 0.0;
  int colourOrder = 0;
  int nextColorOrder;
  Color nextColor;
  double radius1;
  double radius2;
  double width;
  const double offset = 0.0;

  // draw the background
  canvas.drawRect(
      Offset(marginX, marginY) & Size(canvasWidth, canvasHeight),
      Paint()
        ..color = backgroundColor.withOpacity(1.0)
        ..style = PaintingStyle.fill);

  for (int i = 0; i < cellsX; ++i) {
    for (int j = 0; j < cellsY; ++j) {
      parity = (i + j) % 2 == 0;

      final p0 = [
        marginX + borderX + i * sideLength,
        marginY + borderY + j * sideLength
      ];
      final p1 = [
        marginX + borderX + (i + 1) * sideLength,
        marginY + borderY + j * sideLength
      ];
      final p2 = [
        marginX + borderX + (i + 1) * sideLength,
        marginY + borderY + (j + 1) * sideLength
      ];
      final p3 = [
        marginX + borderX + i * sideLength,
        marginY + borderY + (j + 1) * sideLength
      ];

      // Quarter Circles
      final int orientation = oneDirection ? 0 : rnd.nextInt(4);
      switch (orientation) {
        case 0:
          centre1 = p0;
          centre2 = p2;
          startAngle = pi * 0;

        case 1:
          centre1 = p1;
          centre2 = p3;
          startAngle = pi * 0.5;
          parity = !parity;

        case 2:
          centre1 = p2;
          centre2 = p0;
          startAngle = pi * 1.0;

        case 3:
          centre1 = p3;
          centre2 = p1;
          startAngle = pi * 1.5;
          parity = !parity;
      }

      if (resetColors.value == true) {
        colourOrder = 0;
      }

      for (int k = pipes; k > 0; k--) {
        // Choose the next colour
        nextColorOrder = parity ? pipes - colourOrder - 1 : colourOrder;
        colourOrder++;

        if (randomColors.value as bool) {
          nextColor = colorList[rnd.nextInt(numberOfColors.value as int)]
              .withOpacity(opacity.value) as Color;
        } else {
          nextColor = colorList[nextColorOrder % (numberOfColors.value as int)]
              .withOpacity(opacity.value) as Color;
        }

        radius1 = sideLength / pipes * (k - 0.5 + (ratio.value as double) / 2) -
            offset;
        radius2 = sideLength / pipes * (k - 0.5 - (ratio.value as double) / 2) -
            offset;
        width = sideLength / pipes * (ratio.value as double);

        switch (shape) {
          case 'circle':
            drawQuarterArc(canvas, centre1, radius1, startAngle, nextColor);
            drawQuarterArc(canvas, centre1, radius2, startAngle,
                backgroundColor.withOpacity(1.0));

          case 'triangle':
            drawTriangle(
                canvas, centre1, radius1, startAngle, nextColor, pointiness);
            drawTriangle(canvas, centre1, radius2, startAngle,
                backgroundColor.withOpacity(1.0), pointiness);

          case 'line':
            drawTriangle(
                canvas, centre1, radius1, startAngle, nextColor, 1 / sqrt(2));
            drawTriangle(canvas, centre1, radius2, startAngle,
                backgroundColor.withOpacity(1.0), 1 / sqrt(2));

          case 'square':
            drawSquare(
                canvas, centre1, radius1, startAngle, nextColor, pointiness);
            drawSquare(canvas, centre1, radius2, startAngle,
                backgroundColor.withOpacity(1.0), pointiness);
        }

        // fill in the left border
        if (i == 0) {
          if (centre1 == p0) {
            canvas.drawRect(
                Offset(marginX, (centre1[1] + radius2) as double) &
                    Size(borderX, width),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
            //drawRect (fullsize, thumbnail, colour, 0, centre1[1] + group / numberOfColours * (k - 0.5 - ratio / 2), border, group / numberOfColours * ratio);
          }
          if (centre1 == p3) {
            canvas.drawRect(
                Offset(marginX, (centre1[1] - radius2 - width) as double) &
                    Size(borderX, width),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
          }
        }
        // fill in the right border
        if (i == cellsX - 1) {
          if (centre1 == p1) {
            canvas.drawRect(
                Offset(centre1[0] as double, (centre1[1] + radius2) as double) &
                    Size(borderX, width),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
          }
          if (centre1 == p2) {
            canvas.drawRect(
                Offset(centre1[0] as double,
                        (centre1[1] - radius2 - width) as double) &
                    Size(borderX, width),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
            // drawRect (fullsize, thumbnail, colour, centre1[0], centre1[1] - group / numberOfColours * (k - 0.5 + ratio / 2), border, group / numberOfColours * ratio);
          }
        }

        // fill in the top border
        if (j == 0) {
          if (centre1 == p0) {
            canvas.drawRect(
                Offset(centre1[0] + radius2 as double, marginY) &
                    Size(width, borderY),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
            // drawRect (fullsize, thumbnail, colour, centre1[0] + group / numberOfColours * (k - 0.5 - ratio / 2), 0, group / numberOfColours * ratio, border);
          }
          if (centre1 == p1) {
            canvas.drawRect(
                Offset(centre1[0] - radius2 - width as double,
                        marginY) &
                    Size(width, borderY),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
            // drawRect (fullsize, thumbnail, colour, centre1[0] - group / numberOfColours * (k - 0.5 + ratio / 2), 0, group / numberOfColours * ratio, border);
          }
        }

        // fill in the bottom border
        if (j == cellsY - 1) {
          if (centre1 == p3) {
            canvas.drawRect(
                Offset(centre1[0] + radius2 as double, (centre1[1]) as double) &
                    Size(width, borderY),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
            // drawRect (fullsize, thumbnail, colour, centre1[0] + group / numberOfColours * (k - 0.5 - ratio / 2), centre1[1], group / numberOfColours * ratio, border);
          }
          if (centre1 == p2) {
            canvas.drawRect(
                Offset(centre1[0] - radius2 - width as double,
                        (centre1[1]) as double) &
                    Size(width, borderY),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
            // canvas.drawRect(Offset(centre2[0]-radius2 as double, (centre2[1]) as double) & Size(width, borderY), Paint() ..color = nextColor ..style = PaintingStyle.fill);
            // drawRect (fullsize, thumbnail, colour, centre1[0] - group / numberOfColours * (k - 0.5 + ratio / 2), centre1[1], group / numberOfColours * ratio, border);
          }
        }
      }

      if (resetColors.value == true) {
        colourOrder = 0;
      }

      for (int k = pipes; k > 0; k--) {
        // Choose the next colour
        nextColorOrder = parity ? pipes - colourOrder - 1 : colourOrder;
        colourOrder++;

        if (randomColors.value as bool) {
          nextColor = colorList[rnd.nextInt(numberOfColors.value as int)]
              .withOpacity(opacity.value) as Color;
        } else {
          nextColor = colorList[nextColorOrder % (numberOfColors.value as int)]
              .withOpacity(opacity.value) as Color;
        }

        radius1 = sideLength / pipes * (k - 0.5 + (ratio.value as double) / 2) +
            offset;
        radius2 = sideLength / pipes * (k - 0.5 - (ratio.value as double) / 2) +
            offset;
        final double width = sideLength / pipes * (ratio.value as double);

        switch (shape) {
          case 'circle':
            drawQuarterArc(
                canvas, centre2, radius1, startAngle + pi, nextColor);
            drawQuarterArc(canvas, centre2, radius2, startAngle + pi,
                backgroundColor.withOpacity(1.0));

          case 'triangle':
            drawTriangle(canvas, centre2, radius1, startAngle + pi, nextColor,
                pointiness);
            drawTriangle(canvas, centre2, radius2, startAngle + pi,
                backgroundColor.withOpacity(1.0), pointiness);

          case 'line':
            drawTriangle(canvas, centre2, radius1, startAngle + pi, nextColor,
                1 / sqrt(2));
            drawTriangle(canvas, centre2, radius2, startAngle + pi,
                backgroundColor.withOpacity(1.0), 1 / sqrt(2));

          case 'square':
            drawSquare(canvas, centre2, radius1, startAngle + pi, nextColor,
                pointiness);
            drawSquare(canvas, centre2, radius2, startAngle + pi,
                backgroundColor.withOpacity(1.0), pointiness);
        }

        // fill in the left border
        if (i == 0) {
          if (centre2 == p0) {
            canvas.drawRect(
                Offset(marginX, (centre2[1] + radius2) as double) &
                    Size(borderX, width),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
          }
          if (centre2 == p3) {
            canvas.drawRect(
                Offset(marginX, (centre2[1] - radius2 - width) as double) &
                    Size(borderX, width),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
          }
        }
        // fill in the right border
        if (i == cellsX - 1) {
          if (centre2 == p1) {
            canvas.drawRect(
                Offset(centre2[0] as double, (centre2[1] + radius2) as double) &
                    Size(borderX, width),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
            // drawRect (fullsize, thumbnail, colour, centre2[0], centre2[1] + group / numberOfColours * (k - 0.5 - ratio / 2), border, group / numberOfColours * ratio);
          }
          if (centre2 == p2) {
            canvas.drawRect(
                Offset(centre2[0] as double,
                        (centre2[1] - radius2 - width) as double) &
                    Size(borderX, width),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
            // drawRect (fullsize, thumbnail, colour, centre2[0], centre2[1] - group / numberOfColours * (k - 0.5 + ratio / 2), border, group / numberOfColours * ratio);
          }
        }

        // fill in the top border
        if (j == 0) {
          if (centre2 == p0) {
            canvas.drawRect(
                Offset(centre2[0] + radius2 as double, marginY) &
                    Size(width, borderY),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
            // drawRect (fullsize, thumbnail, colour, centre2[0] + group / numberOfColours * (k - 0.5 - ratio / 2), 0, group / numberOfColours * ratio, border);
          }
          if (centre2 == p1) {
            canvas.drawRect(
                Offset(centre2[0] - radius2 - width as double,
                        marginY) &
                    Size(width, borderY),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
            // drawRect (fullsize, thumbnail, colour, centre2[0] - group / numberOfColours * (k - 0.5 + ratio / 2), 0, group / numberOfColours * ratio, border);
          }
        }

        // fill in the bottom border
        if (j == cellsY - 1) {
          if (centre2 == p3) {
            canvas.drawRect(
                Offset(centre2[0] + radius2 as double, (centre2[1]) as double) &
                    Size(width, borderY),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
            // drawRect (fullsize, thumbnail, colour, centre2[0] + group / numberOfColours * (k - 0.5 - ratio / 2), centre2[1], group / numberOfColours * ratio, border);
          }
          if (centre2 == p2) {
            canvas.drawRect(
                Offset(centre2[0] - radius2 - width as double,
                        (centre2[1]) as double) &
                    Size(width, borderY),
                Paint()
                  ..color = nextColor
                  ..style = PaintingStyle.fill);
            // drawRect (fullsize, thumbnail, colour, centre2[0] - group / numberOfColours * (k - 0.5 + ratio / 2), centre2[1], group / numberOfColours * ratio, border);
          }
        }
      }
    }
  }
}

void drawQuarterArc(Canvas canvas, List centre, double radius2,
    double startAngle, Color color) {
  canvas.drawArc(
      Rect.fromCenter(
          center: Offset(centre[0] as double, centre[1] as double),
          height: 2 * radius2,
          width: 2 * radius2),
      startAngle,
      pi / 2,
      true,
      Paint()
        ..isAntiAlias = false
        ..strokeWidth = 0.0
        ..color = color
        ..style = PaintingStyle.fill);
}

void drawTriangle(Canvas canvas, List centre, double radius2, double startAngle,
    Color color, double pointiness) {
  final path = Path();
  path.moveTo(centre[0] as double, centre[1] as double);
  path.lineTo(centre[0] + radius2 * cos(startAngle) as double,
      centre[1] + radius2 * sin(startAngle) as double);
  path.lineTo(
      centre[0] + pointiness * radius2 * cos(startAngle + pi / 4) as double,
      centre[1] + pointiness * radius2 * sin(startAngle + pi / 4) as double);
  path.lineTo(centre[0] + radius2 * cos(startAngle + pi / 2) as double,
      centre[1] + radius2 * sin(startAngle + pi / 2) as double);
  path.close();
  canvas.drawPath(
      path,
      Paint()
        ..isAntiAlias = false
        ..strokeWidth = 0.0
        ..color = color
        ..style = PaintingStyle.fill);
}

void drawSquare(Canvas canvas, List centre, double radius2, double startAngle,
    Color color, double pointiness) {
  final path = Path();
  path.moveTo(centre[0] as double, centre[1] as double);
  path.lineTo(centre[0] + radius2 * cos(startAngle) as double,
      centre[1] + radius2 * sin(startAngle) as double);
  path.lineTo(
      centre[0] + pointiness * radius2 * cos(startAngle + pi / 6) as double,
      centre[1] + pointiness * radius2 * sin(startAngle + pi / 6) as double);
  path.lineTo(
      centre[0] + pointiness * radius2 * cos(startAngle + pi / 3) as double,
      centre[1] + pointiness * radius2 * sin(startAngle + pi / 3) as double);
  path.lineTo(centre[0] + radius2 * cos(startAngle + pi / 2) as double,
      centre[1] + radius2 * sin(startAngle + pi / 2) as double);
  path.close();
  canvas.drawPath(
      path,
      Paint()
        ..isAntiAlias = false
        ..strokeWidth = 0.0
        ..color = color
        ..style = PaintingStyle.fill);
}
