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
  min: 20.0,
  max: 500.0,
  randomMin: 20.0,
  randomMax: 200.0,
  zoom: 100,
  defaultValue: 120.0,
  icon: const Icon(Icons.zoom_in),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel shapeHalfDiagonalTriangle = SettingsModel(
  name: 'shapeHalfDiagonalTriangle',
  settingType: SettingType.bool,
  label: 'Half Triangles',
  tooltip: 'Add half triangles to the shapes',
  defaultValue: true,
  icon: const Icon(OpArtLab.halfTriangle),
  settingCategory: SettingCategory.tool,
  silent: true,
  proFeature: false,
);

SettingsModel shapeCircle = SettingsModel(
  name: 'shapeCircle',
  settingType: SettingType.bool,
  label: 'Circles',
  tooltip: 'Add circles to the shapes',
  defaultValue: true,
  icon: const Icon(OpArtLab.circle),
  settingCategory: SettingCategory.tool,
  silent: true,
  proFeature: false,
);

SettingsModel shapeQuarterCircle = SettingsModel(
  name: 'shapeQuarterCircle',
  settingType: SettingType.bool,
  label: 'Quarter Circles',
  tooltip: 'Add quarter circles to the shapes',
  defaultValue: true,
  icon: const Icon(OpArtLab.quarterCircle),
  settingCategory: SettingCategory.tool,
  silent: true,
  proFeature: false,
);

SettingsModel shapeHalfCircle = SettingsModel(
  name: 'shapeHalfCircle',
  settingType: SettingType.bool,
  label: 'Half Circles',
  tooltip: 'Add half circles to the shapes',
  defaultValue: true,
  icon: const Icon(OpArtLab.halfCircle),
  settingCategory: SettingCategory.tool,
  silent: true,
  proFeature: false,
);

SettingsModel shapeQuarterTriangle = SettingsModel(
  name: 'shapeQuarterTriangle',
  settingType: SettingType.bool,
  label: 'Quarter Triangles',
  tooltip: 'Add quarter triangles to the shapes',
  defaultValue: true,
  icon: const Icon(OpArtLab.quarterTriangle),
  settingCategory: SettingCategory.tool,
  silent: true,
  proFeature: false,
);

SettingsModel shapeQuarterSquare = SettingsModel(
  name: 'shapeQuarterSquare',
  settingType: SettingType.bool,
  label: 'Quarter Squares',
  tooltip: 'Add quarter squares to the shapes',
  defaultValue: true,
  icon: const Icon(OpArtLab.quarterSquare),
  settingCategory: SettingCategory.tool,
  silent: true,
  proFeature: false,
);

SettingsModel shapeMiniCircle = SettingsModel(
  name: 'shapeMiniCircle',
  settingType: SettingType.bool,
  label: 'Mini Circles',
  tooltip: 'Add mini circles to the shapes',
  defaultValue: true,
  icon: const Icon(OpArtLab.miniCircle),
  settingCategory: SettingCategory.tool,
  silent: true,
  proFeature: false,
);

SettingsModel shapeS = SettingsModel(
  name: 'shapeS',
  settingType: SettingType.bool,
  label: 'S Shapes',
  tooltip: 'Add s shapes to the shapes',
  defaultValue: false,
  icon: const Icon(OpArtLab.sShape),
  settingCategory: SettingCategory.tool,
  silent: true,
  proFeature: false,
);

SettingsModel shapeSquaredCircle = SettingsModel(
  name: 'shapeSquaredCircle',
  settingType: SettingType.bool,
  label: 'Squared Circle',
  tooltip: 'Add squared circle shapes to the shapes',
  defaultValue: true,
  icon: const Icon(OpArtLab.squaredCircle),
  settingCategory: SettingCategory.tool,
  silent: true,
  proFeature: false,
);

SettingsModel randomSize = SettingsModel(
  name: 'randomSize',
  settingType: SettingType.bool,
  label: 'Random Size',
  tooltip: 'Randomize the shape size',
  defaultValue: false,
  randomTrue: 0.2,
  icon: const Icon(Icons.adjust),
  settingCategory: SettingCategory.tool,
  silent: true,
  proFeature: true,
);

SettingsModel box = SettingsModel(
  name: 'box',
  settingType: SettingType.bool,
  label: 'Box',
  tooltip: 'Fill in the box',
  defaultValue: true,
  icon: const Icon(Icons.check_box_outline_blank),
  settingCategory: SettingCategory.tool,
  silent: true,
  proFeature: true,
);

SettingsModel recursionDepth = SettingsModel(
  name: 'recursionDepth',
  settingType: SettingType.int,
  label: 'Recursion Depth',
  tooltip: 'The number of recursion steps',
  min: 0,
  max: 5,
  randomMin: 0,
  randomMax: 1,
  defaultValue: 1,
  icon: const Icon(OpArtLab.recursionDepth),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel recursionRatio = SettingsModel(
  name: 'recursionRatio',
  settingType: SettingType.double,
  label: 'Recursion Ratio',
  tooltip: 'The ratio of recursion - 0=never 1=always',
  min: 0.0,
  max: 1.0,
  randomMin: 0.0,
  randomMax: 0.8,
  zoom: 100,
  defaultValue: 0.9,
  icon: const Icon(OpArtLab.recursionRatio),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel lineWidth = SettingsModel(
  name: 'lineWidth',
  settingType: SettingType.double,
  label: 'Outline Width',
  tooltip: 'The width of the outline',
  min: 0.0,
  max: 1.0,
  zoom: 100,
  defaultValue: 0.1,
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
  proFeature: false,
  onChange: () {
    resetAllDefaults();
  },
  silent: true,
);

List<SettingsModel> initializeShapesAttributes() {
  return [
    reDraw,
    zoomOpArt,
    shapeHalfDiagonalTriangle,
    shapeCircle,
    shapeQuarterCircle,
    shapeHalfCircle,
    shapeQuarterTriangle,
    shapeQuarterSquare,
    shapeMiniCircle,
    shapeS,
    shapeSquaredCircle,
    randomSize,
    box,
    recursionDepth,
    recursionRatio,
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

void paintShapes(
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
  final double imageWidth = canvasWidth;
  final double imageHeight = canvasHeight;

  // colour in the canvas
  //a rectangle
  canvas.drawRect(Offset(borderX, borderY) & Size(imageWidth, imageHeight * 2),
      Paint()..style = PaintingStyle.fill);

  // Work out the X and Y
  final int cellsX =
      (canvasWidth / (zoomOpArt.value as double) + 0.9999999).toInt();
  borderX = (canvasWidth - (zoomOpArt.value as num) * cellsX) / 2;

  final int cellsY =
      (canvasHeight / (zoomOpArt.value as num) + 0.9999999).toInt();
  borderY = (canvasHeight - (zoomOpArt.value as num) * cellsY) / 2;

  int colourOrder = 0;

  // Now make some art

  final List shapesArray = [];
  if (shapeHalfDiagonalTriangle.value == true) {
    shapesArray.add('shapeHalfDiagonalTriangle');
  }
  if (shapeCircle.value == true) {
    shapesArray.add('shapeCircle');
  }
  if (shapeQuarterCircle.value == true) {
    shapesArray.add('shapeQuarterCircle');
  }
  if (shapeHalfCircle.value == true) {
    shapesArray.add('shapeHalfCircle');
  }
  if (shapeQuarterTriangle.value == true) {
    shapesArray.add('shapeQuarterTriangle');
  }
  if (shapeQuarterSquare.value == true) {
    shapesArray.add('shapeQuarterSquare');
  }
  if (shapeMiniCircle.value == true) {
    shapesArray.add('shapeMiniCircle');
  }
  if (shapeS.value == true) {
    shapesArray.add('shapeS');
  }
  if (shapeSquaredCircle.value == true) {
    shapesArray.add('shapeSquaredCircle');
  }

  final double side = zoomOpArt.value as double;

  // reset the colours
  colourOrder = 0;

  for (int j = 0; j < cellsY; j++) {
    for (int i = 0; i < cellsX; i++) {
      colourOrder = drawSquare(
          canvas,
          rnd,
          opArt.palette.colorList,
          colourOrder,
          shapesArray,
          [borderX + i * side, borderY + j * side],
          side,
          0,
          randomSize.value as bool ? rnd.nextDouble() : 1);
    }
  }
}

int drawSquare(
    Canvas canvas,
    Random rnd,
    List palette,
    int colourOrder,
    List shapesArray,
    List<double> pA,
    double side,
    int recursion,
    double ratio) {
  Color nextColor;

  if (recursion < (recursionDepth.value as num) &&
      rnd.nextDouble() < (recursionRatio.value as num)) {
    colourOrder = drawSquare(canvas, rnd, palette, colourOrder, shapesArray, pA,
        side / 2, recursion + 1, ratio);
    colourOrder = drawSquare(canvas, rnd, palette, colourOrder, shapesArray,
        [pA[0] + side / 2, pA[1]], side / 2, recursion + 1, ratio);
    colourOrder = drawSquare(canvas, rnd, palette, colourOrder, shapesArray,
        [pA[0] + side / 2, pA[1] + side / 2], side / 2, recursion + 1, ratio);
    colourOrder = drawSquare(canvas, rnd, palette, colourOrder, shapesArray,
        [pA[0], pA[1] + side / 2], side / 2, recursion + 1, ratio);
  } else {
    // Centre of the square
    final List<double> pO = [pA[0] + side / 2, pA[1] + side / 2];

    // corners of the square
    final List<double> pB = [pA[0] + side, pA[1]];
    final List<double> pC = [pA[0] + side, pA[1] + side];
    final List<double> pD = [pA[0], pA[1] + side];

    if (box.value == true) {
      // Choose the next colour
      colourOrder++;
      nextColor = (randomColors.value as bool)
          ? palette[colourOrder % (numberOfColors.value as int)] as Color
          : palette[rnd.nextInt(numberOfColors.value as int)] as Color;

      // fill the square
      canvas.drawRect(
          Offset(pA[0], pA[1]) & Size(side, side),
          Paint()
            ..style = PaintingStyle.fill
            ..isAntiAlias = false
            ..color = nextColor.withOpacity(opacity.value as double));
    }

    // now  draw the shape
    if (shapesArray.isNotEmpty) {
      // Choose the next colour
      colourOrder++;
      nextColor = (randomColors.value as bool)
          ? palette[colourOrder % (numberOfColors.value as int)] as Color
          : palette[rnd.nextInt(numberOfColors.value as int)] as Color;
      final Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = false
        ..color = nextColor.withOpacity(opacity.value as double);

      final Path shape = Path();

      // pick a random shape
      switch (shapesArray[rnd.nextInt(shapesArray.length)] as String) {
        case 'shapeHalfDiagonalTriangle': // half diagonal triangle

          final shapeOrientation = rnd.nextInt(4);
          switch (shapeOrientation) {
            case 0:
              shape.moveTo(pA[0], pA[1]);
              shape.lineTo(pA[0] + side * ratio, pA[1]);
              shape.lineTo(pA[0], pA[1] + side * ratio);

            case 1:
              shape.moveTo(pB[0] - side * ratio, pB[1]);
              shape.lineTo(pB[0], pB[1]);
              shape.lineTo(pB[0], pB[1] + side * ratio);

            case 2:
              shape.moveTo(pC[0], pC[1] - side * ratio);
              shape.lineTo(pC[0], pC[1]);
              shape.lineTo(pC[0] - side * ratio, pC[1]);

            case 3:
              shape.moveTo(pD[0], pD[1] - side * ratio);
              shape.lineTo(pD[0] + side * ratio, pD[1]);
              shape.lineTo(pD[0], pD[1]);
          }

          canvas.drawPath(shape, paint);


        case 'shapeCircle': // circle

          canvas.drawCircle(Offset(pO[0], pO[1]), ratio * side / 2, paint);


        case 'shapeQuarterCircle': // quarter circle

          switch (rnd.nextInt(4)) {
            case 0: // centre top left
              canvas.drawArc(
                  Rect.fromCenter(
                      center: Offset(pO[0] - side / 2, pO[1] - side / 2),
                      height: ratio * side * 2,
                      width: ratio * side * 2),
                  pi * 0.0,
                  pi * 0.5,
                  true,
                  paint);
            case 1: // centre top right
              canvas.drawArc(
                  Rect.fromCenter(
                      center: Offset(pO[0] + side / 2, pO[1] - side / 2),
                      height: ratio * side * 2,
                      width: ratio * side * 2),
                  pi * 0.5,
                  pi * 0.5,
                  true,
                  paint);
            case 2: // centre bottom right
              canvas.drawArc(
                  Rect.fromCenter(
                      center: Offset(pO[0] + side / 2, pO[1] + side / 2),
                      height: ratio * side * 2,
                      width: ratio * side * 2),
                  pi * 1.0,
                  pi * 0.5,
                  true,
                  paint);
            case 3: // centre bottom left
              canvas.drawArc(
                  Rect.fromCenter(
                      center: Offset(pO[0] - side / 2, pO[1] + side / 2),
                      height: ratio * side * 2,
                      width: ratio * side * 2),
                  pi * 1.5,
                  pi * 0.5,
                  true,
                  paint);
          }

        case 'shapeHalfCircle': // half circle

          switch (rnd.nextInt(4)) {
            case 0: // centre top
              canvas.drawArc(
                  Rect.fromCenter(
                      center: Offset(pO[0], pO[1] - side / 2),
                      height: ratio * side,
                      width: ratio * side),
                  pi * 0.0,
                  pi * 1.0,
                  true,
                  paint);

            case 1: // centre right
              canvas.drawArc(
                  Rect.fromCenter(
                      center: Offset(pO[0] + side / 2, pO[1]),
                      height: ratio * side,
                      width: ratio * side),
                  pi * 0.5,
                  pi * 1.0,
                  true,
                  paint);

            case 2: // centre bottom
              canvas.drawArc(
                  Rect.fromCenter(
                      center: Offset(pO[0], pO[1] + side / 2),
                      height: ratio * side,
                      width: ratio * side),
                  pi * 1.0,
                  pi * 1.0,
                  true,
                  paint);

            case 3: // centre left
              canvas.drawArc(
                  Rect.fromCenter(
                      center: Offset(pO[0] - side / 2, pO[1]),
                      height: ratio * side,
                      width: ratio * side),
                  pi * 1.5,
                  pi * 1.0,
                  true,
                  paint);
          }

        case 'shapeQuarterTriangle': // quarter triangle

          switch (rnd.nextInt(4)) {
            case 0:
              shape.moveTo(pO[0], pO[1]);
              shape.lineTo(pB[0], pB[1]);
              shape.lineTo(pC[0], pC[1]);

            case 1:
              shape.moveTo(pO[0], pO[1]);
              shape.lineTo(pC[0], pC[1]);
              shape.lineTo(pD[0], pD[1]);

            case 2:
              shape.moveTo(pO[0], pO[1]);
              shape.lineTo(pD[0], pD[1]);
              shape.lineTo(pA[0], pA[1]);

            case 3:
              shape.moveTo(pO[0], pO[1]);
              shape.lineTo(pA[0], pA[1]);
              shape.lineTo(pB[0], pB[1]);
          }

          canvas.drawPath(shape, paint);


        case 'shapeQuarterSquare': // quarter square

          switch (rnd.nextInt(4)) {
            case 0:
              shape.moveTo(pA[0], pA[1]);
              shape.lineTo((pA[0] + pB[0]) / 2, (pA[1] + pB[1]) / 2);
              shape.lineTo(pO[0], pO[1]);
              shape.lineTo((pA[0] + pD[0]) / 2, (pA[1] + pD[1]) / 2);

            case 1:
              shape.moveTo(pB[0], pB[1]);
              shape.lineTo((pB[0] + pC[0]) / 2, (pB[1] + pC[1]) / 2);
              shape.lineTo(pO[0], pO[1]);
              shape.lineTo((pA[0] + pB[0]) / 2, (pA[1] + pB[1]) / 2);

            case 2:
              shape.moveTo(pC[0], pC[1]);
              shape.lineTo((pC[0] + pD[0]) / 2, (pC[1] + pD[1]) / 2);
              shape.lineTo(pO[0], pO[1]);
              shape.lineTo((pB[0] + pC[0]) / 2, (pB[1] + pC[1]) / 2);

            case 3:
              shape.moveTo(pD[0], pD[1]);
              shape.lineTo((pD[0] + pA[0]) / 2, (pD[1] + pA[1]) / 2);
              shape.lineTo(pO[0], pO[1]);
              shape.lineTo((pC[0] + pD[0]) / 2, (pC[1] + pD[1]) / 2);
          }
          canvas.drawPath(shape, paint);


        case 'shapeMiniCircle': // mini circle
          switch (rnd.nextInt(4)) {
            case 0:
              canvas.drawCircle(
                  Offset(pO[0] - side / 4, pO[1] - side / 4), side / 4, paint);
            case 1:
              canvas.drawCircle(
                  Offset(pO[0] - side / 4, pO[1] + side / 4), side / 4, paint);
            case 2:
              canvas.drawCircle(
                  Offset(pO[0] + side / 4, pO[1] - side / 4), side / 4, paint);
            case 3:
              canvas.drawCircle(
                  Offset(pO[0] + side / 4, pO[1] + side / 4), side / 4, paint);
          }

        case 'shapeS':
          switch (rnd.nextInt(4)) {
            case 0:
              shape.moveTo(pA[0], pA[1]);
              shape.lineTo((pA[0] + pB[0]) / 2, (pA[1] + pB[1]) / 2);
              shape.quadraticBezierTo((pB[0] * 3 + pC[0]) / 4,
                  (pB[1] * 3 + pC[1]) / 4, pO[0], pO[1]);
              shape.quadraticBezierTo(
                  (pD[0] * 3 + pA[0]) / 4,
                  (pD[1] * 3 + pA[1]) / 4,
                  (pC[0] + pD[0]) / 2,
                  (pC[1] + pD[1]) / 2);
              shape.lineTo(pD[0], pD[1]);


            case 1:
              shape.moveTo(pB[0], pB[1]);
              shape.lineTo((pB[0] + pC[0]) / 2, (pB[1] + pC[1]) / 2);
              shape.quadraticBezierTo((pC[0] * 3 + pD[0]) / 4,
                  (pC[1] * 3 + pD[1]) / 4, pO[0], pO[1]);
              shape.quadraticBezierTo(
                  (pA[0] * 3 + pB[0]) / 4,
                  (pA[1] * 3 + pB[1]) / 4,
                  (pD[0] + pA[0]) / 2,
                  (pD[1] + pA[1]) / 2);
              shape.lineTo(pA[0], pA[1]);


            case 2:
              shape.moveTo(pC[0], pC[1]);
              shape.lineTo((pC[0] + pD[0]) / 2, (pC[1] + pD[1]) / 2);
              shape.quadraticBezierTo((pD[0] * 3 + pA[0]) / 4,
                  (pD[1] * 3 + pA[1]) / 4, pO[0], pO[1]);
              shape.quadraticBezierTo(
                  (pB[0] * 3 + pC[0]) / 4,
                  (pB[1] * 3 + pC[1]) / 4,
                  (pA[0] + pB[0]) / 2,
                  (pA[1] + pB[1]) / 2);
              shape.lineTo(pB[0], pB[1]);


            case 3:
              shape.moveTo(pD[0], pD[1]);
              shape.lineTo((pD[0] + pA[0]) / 2, (pD[1] + pA[1]) / 2);
              shape.quadraticBezierTo((pA[0] * 3 + pB[0]) / 4,
                  (pA[1] * 3 + pB[1]) / 4, pO[0], pO[1]);
              shape.quadraticBezierTo(
                  (pC[0] * 3 + pD[0]) / 4,
                  (pC[1] * 3 + pD[1]) / 4,
                  (pB[0] + pC[0]) / 2,
                  (pB[1] + pC[1]) / 2);
              shape.lineTo(pC[0], pC[1]);

          }

          canvas.drawPath(shape, paint);


        case 'shapeSquaredCircle':
          switch (rnd.nextInt(4)) {
            case 0:
              canvas.drawArc(
                  Rect.fromCenter(
                      center: Offset(pO[0], pO[1]), width: side, height: side),
                  pi * 3 / 2,
                  pi,
                  true,
                  paint);
              canvas.drawRect(
                  Offset(pA[0], pA[1]) & Size(side / 2, side), paint);

            case 1:
              canvas.drawArc(
                  Rect.fromCenter(
                      center: Offset(pO[0], pO[1]), width: side, height: side),
                  pi * 1 / 2,
                  pi,
                  true,
                  paint);
              canvas.drawRect(
                  Offset(pB[0] - side / 2, pB[1]) & Size(side / 2, side),
                  paint);

            case 2:
              canvas.drawArc(
                  Rect.fromCenter(
                      center: Offset(pO[0], pO[1]), width: side, height: side),
                  pi * 0 / 2,
                  pi,
                  true,
                  paint);
              canvas.drawRect(
                  Offset(pA[0], pA[1]) & Size(side, side / 2), paint);

            case 3:
              canvas.drawArc(
                  Rect.fromCenter(
                      center: Offset(pO[0], pO[1]), width: side, height: side),
                  pi * 2 / 2,
                  pi,
                  true,
                  paint);
              canvas.drawRect(
                  Offset(pA[0], pA[1] + side / 2) & Size(side, side / 2),
                  paint);
          }

      }
    }
  }

  return colourOrder;
}
