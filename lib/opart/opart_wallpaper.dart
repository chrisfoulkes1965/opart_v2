import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opart_v2/app_state.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/model_palette.dart';
import 'package:opart_v2/model_settings.dart';
import 'package:opart_v2/opart_icons.dart';

List<String> list = [];

SettingsModel zoomOpArt = SettingsModel(
  name: 'zoomOpArt',
  settingType: SettingType.double,
  label: 'Radius',
  tooltip: 'The radius of the shapes',
  min: 20.0,
  max: 500.0,
  zoom: 100,
  defaultValue: 100.0,
  icon: const Icon(Icons.zoom_in),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel shape = SettingsModel(
  name: 'shape',
  settingType: SettingType.list,
  label: 'Shape',
  tooltip: 'The shape in the cell',
  defaultValue: 'squaricle',
  icon: const Icon(Icons.settings),
  options: ['circle', 'square', 'squaricle', 'polygon', 'heart', 'random'],
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel step = SettingsModel(
  name: 'step',
  settingType: SettingType.double,
  label: 'Step',
  tooltip: 'The decrease ratio of concentric shapes',
  min: 0.05,
  max: 1.0,
  zoom: 100,
  defaultValue: 0.3,
  icon: const Icon(Icons.control_point),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel ratio = SettingsModel(
  name: 'ratio',
  settingType: SettingType.double,
  label: 'Ratio',
  tooltip: 'The ratio of the shape to the box',
  min: 0.75,
  max: 1.75,
  zoom: 100,
  defaultValue: 1.0,
  icon: const Icon(OpArtLab.wallpaperRatio),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel driftX = SettingsModel(
  name: 'driftX',
  settingType: SettingType.double,
  label: 'Horizontal Drift',
  tooltip: 'The drift in the horizontal axis',
  min: -5.0,
  max: 5.0,
  randomMin: -2.0,
  randomMax: 2.0,
  zoom: 100,
  defaultValue: 0.0,
  icon: const Icon(OpArtLab.horizontalDrift),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel driftY = SettingsModel(
  name: 'driftY',
  settingType: SettingType.double,
  label: 'Vertical Drift',
  tooltip: 'The drift in the vertical axis',
  min: -5.0,
  max: 5.0,
  randomMin: -2.0,
  randomMax: 2.0,
  zoom: 100,
  defaultValue: 0.0,
  icon: const Icon(OpArtLab.verticalDrift),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel alternateDrift = SettingsModel(
  name: 'alternateDrift',
  settingType: SettingType.bool,
  label: 'Alternate Drift',
  tooltip: 'Alternate the drift',
  defaultValue: true,
  icon: const Icon(Icons.gamepad),
  proFeature: false,
  silent: true,
);

SettingsModel box = SettingsModel(
  name: 'box',
  settingType: SettingType.bool,
  label: 'Box',
  tooltip: 'Fill in the box',
  defaultValue: true,
  icon: const Icon(Icons.check_box_outline_blank),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  silent: true,
);

SettingsModel offsetX = SettingsModel(
  name: 'offsetX',
  settingType: SettingType.double,
  label: 'Horizontal Offset',
  tooltip: 'The offset in the horizontal axis',
  min: -2.0,
  max: 2.0,
  zoom: 100,
  defaultValue: 0.0,
  icon: const Icon(OpArtLab.horizontalOffset),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel offsetY = SettingsModel(
  name: 'offsetY',
  settingType: SettingType.double,
  label: 'Vertical Offset',
  tooltip: 'The offset in the vertical axis',
  min: -2.0,
  max: 2.0,
  zoom: 100,
  defaultValue: 0.0,
  icon: const Icon(OpArtLab.verticalOffset),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel rotate = SettingsModel(
  name: 'rotate',
  settingType: SettingType.double,
  label: 'Rotate',
  tooltip: 'The shape rotation',
  min: 0.0,
  max: pi,
  zoom: 200,
  defaultValue: 0.0,
  icon: const Icon(Icons.rotate_right),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel rotateStep = SettingsModel(
  name: 'rotateStep',
  settingType: SettingType.double,
  label: 'Rotate Step',
  tooltip: 'The rate of increase of the rotation',
  min: 0.0,
  max: 2.0,
  zoom: 100,
  defaultValue: 0.0,
  icon: const Icon(Icons.screen_rotation),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel randomRotation = SettingsModel(
  name: 'randomRotation',
  settingType: SettingType.bool,
  label: 'Random Rotate',
  tooltip: 'The random shape rotation',
  defaultValue: false,
  icon: const Icon(Icons.crop_rotate),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  silent: true,
);

SettingsModel squareness = SettingsModel(
  name: 'squareness',
  settingType: SettingType.double,
  label: 'Squareness',
  tooltip: 'The squareness of the shape',
  min: -3.0,
  max: 1.0,
  randomMin: -0.5,
  randomMax: 1.0,
  zoom: 100,
  defaultValue: 0.5,
  icon: const Icon(Icons.center_focus_weak),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel squeezeX = SettingsModel(
  name: 'squeezeX',
  settingType: SettingType.double,
  label: 'Horizontal Squeeze',
  tooltip: 'The squeeze in the horizontal axis',
  min: 0.5,
  max: 1.5,
  zoom: 100,
  defaultValue: 1.0,
  icon: const Icon(Icons.more_horiz),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel squeezeY = SettingsModel(
  name: 'squeezeY',
  settingType: SettingType.double,
  label: 'Vertical Squeeze',
  tooltip: 'The squeeze in the vertical axis',
  min: 0.5,
  max: 1.5,
  zoom: 100,
  defaultValue: 1.0,
  icon: const Icon(Icons.more_vert),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel numberOfSides = SettingsModel(
  name: 'numberOfSides',
  settingType: SettingType.int,
  label: 'Number Of Sides',
  tooltip: 'The number of sides of the polygon',
  min: 1,
  max: 15,
  defaultValue: 6,
  icon: const Icon(Icons.star),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel randomPetals = SettingsModel(
  name: 'randomPetals',
  settingType: SettingType.bool,
  label: 'Random Petals',
  tooltip: 'Random Petals',
  defaultValue: true,
  icon: const Icon(Icons.stars),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  silent: true,
);

SettingsModel lineWidth = SettingsModel(
  name: 'lineWidth',
  settingType: SettingType.double,
  label: 'Outline Width',
  tooltip: 'The width of the outline',
  min: 0.0,
  max: 10.0,
  zoom: 100,
  defaultValue: 0.1,
  icon: const Icon(Icons.line_weight),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

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

SettingsModel resetColors = SettingsModel(
  name: 'resetColors',
  settingType: SettingType.bool,
  label: 'Reset Colors',
  tooltip: 'Reset the colours for each cell',
  defaultValue: false,
  icon: const Icon(Icons.gamepad),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  silent: true,
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
    'linear complementary',
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

List<SettingsModel> initializeWallpaperAttributes() {
  return [
    zoomOpArt,
    shape,
    step,
    ratio,
    offsetX,
    offsetY,
    driftX,
    driftY,
    alternateDrift,
    box,
    rotate,
    rotateStep,
    randomRotation,
    squareness,
    squeezeX,
    squeezeY,
    numberOfSides,
    randomPetals,
    backgroundColor,
    lineColor,
    lineWidth,
    randomColors,
    numberOfColors,
    resetColors,
    paletteType,
    paletteList,
    opacity,
    resetDefaults,
  ];
}

void paintWallpaper(
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
  double borderX = 0;
  double borderY = 0;

  // colour in the canvas
  canvas.drawRect(
    Offset(borderX, borderY) & Size(canvasWidth, canvasHeight),
    Paint()
      ..color = backgroundColor.colorValue
      ..style = PaintingStyle.fill,
  );

  // Work out the X and Y
  final int cellsX =
      (canvasWidth / ((zoomOpArt.numValue) * (squeezeX.numValue)) + 1.9999999)
          .toInt();
  borderX =
      (canvasWidth - (zoomOpArt.numValue) * (squeezeX.numValue) * cellsX) / 2;

  final int cellsY =
      (canvasHeight / ((zoomOpArt.numValue) * (squeezeY.numValue)) + 1.9999999)
          .toInt();
  borderY =
      (canvasHeight - (zoomOpArt.numValue) * (squeezeY.numValue) * cellsY) / 2;

  int colourOrder = 0;

  // Now make some art

  // fill
  const bool fill = true;

  int extraCellsX = 0;
  int extraCellsY = 0;
  if (fill) {
    extraCellsX = cellsX * 2 ~/ (squeezeX.numValue);
    extraCellsY = cellsY * 2 ~/ (squeezeY.numValue);
  }

  // work out the radius from the width and the cells
  final double radius = (zoomOpArt.numValue) / 2;

  // double localSquareness = sin(2500 * animationVariable);
  final double localSquareness = squareness.doubleValue;

  for (int j = 0 - extraCellsY; j < cellsY + extraCellsY; j++) {
    for (int i = 0 - extraCellsX; i < cellsX + extraCellsX; i++) {
      int k = 0; // count the steps

      double dX = 0;
      double dY = 0;

      double stepRadius =
          (radius - (lineWidth.doubleValue) / 2) * (ratio.doubleValue);
      final double localStep = (step.numValue) * radius;

      double localRotate = rotate.doubleValue;
      if (randomRotation.boolValue) {
        localRotate = rnd.nextDouble() * (rotate.numValue);
      }
      if (alternateDrift.boolValue && (i + j).isEven) {
        localRotate = 0 - localRotate;
      }

      // Number of petals
      var localNumberOfPetals = numberOfSides.intValue;
      if (randomPetals.boolValue) {
        localNumberOfPetals = rnd.nextInt(numberOfSides.intValue) + 3;
      }

      // Centre of the square
      List<double> pO = [
        borderX +
            radius * (1 - (squeezeX.numValue)) +
            dX +
            (radius * (offsetX.numValue) * j) +
            (i * 2 + 1) * radius * (squeezeX.numValue),
        borderY +
            radius * (1 - (squeezeY.numValue)) +
            dY +
            (radius * (offsetY.numValue) * i) +
            (j * 2 + 1) * radius * (squeezeY.numValue),
      ];

      // reset the colours
      Color nextColor;
      if (resetColors.boolValue) {
        colourOrder = 0;
      }

      if (box.boolValue) {
        final List<double> pA = [
          pO[0] + radius * sqrt(2) * cos(pi * (5 / 4 + localRotate)),
          pO[1] + radius * sqrt(2) * sin(pi * (5 / 4 + localRotate)),
        ];
        final List<double> pB = [
          pO[0] + radius * sqrt(2) * cos(pi * (7 / 4 + localRotate)),
          pO[1] + radius * sqrt(2) * sin(pi * (7 / 4 + localRotate)),
        ];
        final List<double> pC = [
          pO[0] + radius * sqrt(2) * cos(pi * (1 / 4 + localRotate)),
          pO[1] + radius * sqrt(2) * sin(pi * (1 / 4 + localRotate)),
        ];
        final List<double> pD = [
          pO[0] + radius * sqrt(2) * cos(pi * (3 / 4 + localRotate)),
          pO[1] + radius * sqrt(2) * sin(pi * (3 / 4 + localRotate)),
        ];

        // Choose the next colour
        colourOrder++;
        nextColor =
            opArt.palette.colorList[colourOrder % (numberOfColors.intValue)];
        if (randomColors.boolValue) {
          nextColor =
              opArt.palette.colorList[rnd.nextInt(numberOfColors.intValue)];
        }

        // fill the square
        final Path path = Path();
        path.moveTo(pA[0], pA[1]);
        path.lineTo(pB[0], pB[1]);
        path.lineTo(pC[0], pC[1]);
        path.lineTo(pD[0], pD[1]);
        path.close();

        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.fill
            ..color = nextColor.withValues(alpha: opacity.doubleValue),
        );

        // if (lineWidth > 0) {
        //   canvas.drawPath(path, Paint() ..style = PaintingStyle.stroke ..strokeWidth = lineWidth ..color = lineColor);
        // }
      }

      do {
        // drift...
        pO = [pO[0] + dX, pO[1] + dY];

        //  options: ['circle', 'square', 'squaricle', 'polygon', 'heart', 'random'],
        String shapeOption = shape.stringValue;
        if (shapeOption == 'random') {
          shapeOption = [
            'circle',
            'square',
            'squaricle',
            'polygon',
            'heart',
            'random',
          ][rnd.nextInt(5)];
        }
        switch (shapeOption) {
          case 'circle':

            // Choose the next colour
            colourOrder++;
            nextColor = opArt
                .palette.colorList[colourOrder % (numberOfColors.intValue)];
            if (randomColors.boolValue) {
              nextColor =
                  opArt.palette.colorList[rnd.nextInt(numberOfColors.intValue)];
            }

            canvas.drawCircle(
              Offset(pO[0], pO[1]),
              stepRadius,
              Paint()
                ..style = PaintingStyle.fill
                ..color = nextColor.withValues(alpha: opacity.doubleValue),
            );
            canvas.drawCircle(
              Offset(pO[0], pO[1]),
              stepRadius,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.doubleValue
                ..color = (lineColor.colorValue).withValues(
                  alpha: opacity.doubleValue,
                ),
            );

          case 'square':
            final Path square = Path();

            square.moveTo(
              (pO[0]) + stepRadius * sqrt(2) * cos(pi * (1 / 4 + localRotate)),
              (pO[1]) + stepRadius * sqrt(2) * sin(pi * (1 / 4 + localRotate)),
            );

            square.lineTo(
              (pO[0]) + stepRadius * sqrt(2) * cos(pi * (3 / 4 + localRotate)),
              (pO[1]) + stepRadius * sqrt(2) * sin(pi * (3 / 4 + localRotate)),
            );

            square.lineTo(
              (pO[0]) + stepRadius * sqrt(2) * cos(pi * (5 / 4 + localRotate)),
              (pO[1]) + stepRadius * sqrt(2) * sin(pi * (5 / 4 + localRotate)),
            );

            square.lineTo(
              (pO[0]) + stepRadius * sqrt(2) * cos(pi * (7 / 4 + localRotate)),
              (pO[1]) + stepRadius * sqrt(2) * sin(pi * (7 / 4 + localRotate)),
            );

            square.close();

            // Choose the next colour
            colourOrder++;
            nextColor = opArt
                .palette.colorList[colourOrder % (numberOfColors.intValue)];
            if (randomColors.boolValue) {
              nextColor =
                  opArt.palette.colorList[rnd.nextInt(numberOfColors.intValue)];
            }

            canvas.drawPath(
              square,
              Paint()
                ..style = PaintingStyle.fill
                ..color = nextColor.withValues(alpha: opacity.doubleValue),
            );
            canvas.drawPath(
              square,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.doubleValue
                ..color = (lineColor.colorValue).withValues(
                  alpha: opacity.doubleValue,
                ),
            );

            square.reset();

          case 'squaricle':
            final double curveCentreRadius =
                stepRadius * sqrt(2) * (squareness.doubleValue);
            final double curveRadius =
                stepRadius * sqrt(2) * (1 - (squareness.doubleValue));

            final Path squaricle = Path();

            squaricle.arcTo(
              Rect.fromCenter(
                center: Offset(
                  (pO[0]) + curveCentreRadius * cos(pi * (1 / 4 + localRotate)),
                  (pO[1]) + curveCentreRadius * sin(pi * (1 / 4 + localRotate)),
                ),
                height: curveRadius,
                width: curveRadius,
              ),
              pi * (0 / 2 + localRotate),
              pi / 2,
              false,
            );

            squaricle.arcTo(
              Rect.fromCenter(
                center: Offset(
                  (pO[0]) + curveCentreRadius * cos(pi * (3 / 4 + localRotate)),
                  (pO[1]) + curveCentreRadius * sin(pi * (3 / 4 + localRotate)),
                ),
                height: curveRadius,
                width: curveRadius,
              ),
              pi * (1 / 2 + localRotate),
              pi / 2,
              false,
            );

            squaricle.arcTo(
              Rect.fromCenter(
                center: Offset(
                  (pO[0]) + curveCentreRadius * cos(pi * (5 / 4 + localRotate)),
                  (pO[1]) + curveCentreRadius * sin(pi * (5 / 4 + localRotate)),
                ),
                height: curveRadius,
                width: curveRadius,
              ),
              pi * (2 / 2 + localRotate),
              pi / 2,
              false,
            );

            squaricle.arcTo(
              Rect.fromCenter(
                center: Offset(
                  (pO[0]) + curveCentreRadius * cos(pi * (7 / 4 + localRotate)),
                  (pO[1]) + curveCentreRadius * sin(pi * (7 / 4 + localRotate)),
                ),
                height: curveRadius,
                width: curveRadius,
              ),
              pi * (3 / 2 + localRotate),
              pi / 2,
              false,
            );

            squaricle.close();

            // Choose the next colour
            colourOrder++;
            nextColor = opArt
                .palette.colorList[colourOrder % (numberOfColors.intValue)];
            if (randomColors.boolValue) {
              nextColor =
                  opArt.palette.colorList[rnd.nextInt(numberOfColors.intValue)];
            }

            canvas.drawPath(
              squaricle,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.doubleValue
                ..color = (lineColor.colorValue).withValues(
                  alpha: opacity.doubleValue,
                ),
            );
            canvas.drawPath(
              squaricle,
              Paint()
                ..style = PaintingStyle.fill
                ..color = nextColor.withValues(alpha: opacity.doubleValue),
            );

            squaricle.reset();

          case 'star':
            for (var p = 0; p < localNumberOfPetals; p++) {
              final List<double> petalPoint = [
                pO[0] +
                    stepRadius *
                        cos(
                          localRotate * pi + p * pi * 2 / localNumberOfPetals,
                        ),
                pO[1] +
                    stepRadius *
                        sin(
                          localRotate * pi + p * pi * 2 / localNumberOfPetals,
                        ),
              ];

              final List<double> petalMidPointA = [
                pO[0] +
                    localSquareness *
                        stepRadius *
                        cos(
                          localRotate * pi +
                              (p - 1) * pi * 2 / localNumberOfPetals,
                        ),
                pO[1] +
                    localSquareness *
                        stepRadius *
                        sin(
                          localRotate * pi +
                              (p - 1) * pi * 2 / localNumberOfPetals,
                        ),
              ];

              final List<double> petalMidPointP = [
                pO[0] +
                    localSquareness *
                        stepRadius *
                        cos(
                          localRotate * pi +
                              (p + 1) * pi * 2 / localNumberOfPetals,
                        ),
                pO[1] +
                    localSquareness *
                        stepRadius *
                        sin(
                          localRotate * pi +
                              (p + 1) * pi * 2 / localNumberOfPetals,
                        ),
              ];

              final Path star = Path();

              star.moveTo(pO[0], pO[1]);
              star.quadraticBezierTo(
                petalMidPointA[0],
                petalMidPointA[1],
                petalPoint[0],
                petalPoint[1],
              );
              star.quadraticBezierTo(
                petalMidPointP[0],
                petalMidPointP[1],
                pO[0],
                pO[1],
              );
              star.close();

              // Choose the next colour
              colourOrder++;
              nextColor = opArt
                  .palette.colorList[colourOrder % (numberOfColors.intValue)];
              if (randomColors.boolValue) {
                nextColor = opArt
                    .palette.colorList[rnd.nextInt(numberOfColors.intValue)];
              }

              canvas.drawPath(
                star,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = lineWidth.doubleValue
                  ..color = (lineColor.colorValue).withValues(
                    alpha: opacity.doubleValue,
                  ),
              );
              canvas.drawPath(
                star,
                Paint()
                  ..style = PaintingStyle.fill
                  ..color = nextColor.withValues(alpha: opacity.doubleValue),
              );
            }

          case 'polygon':
            final Path polygon = Path();

            polygon.moveTo(
              (pO[0]) + stepRadius * cos(localRotate),
              (pO[1]) + stepRadius * sin(localRotate),
            );

            for (int s = 1; s < (numberOfSides.intValue); s++) {
              polygon.lineTo(
                (pO[0]) +
                    stepRadius *
                        cos(
                          pi * 2 * s / (numberOfSides.intValue) + localRotate,
                        ),
                (pO[1]) +
                    stepRadius *
                        sin(
                          pi * 2 * s / (numberOfSides.intValue) + localRotate,
                        ),
              );
            }

            polygon.close();

            // Choose the next colour
            colourOrder++;
            nextColor = opArt
                .palette.colorList[colourOrder % (numberOfColors.intValue)];
            if (randomColors.boolValue) {
              nextColor =
                  opArt.palette.colorList[rnd.nextInt(numberOfColors.intValue)];
            }

            canvas.drawPath(
              polygon,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.doubleValue
                ..color = (lineColor.colorValue).withValues(
                  alpha: opacity.doubleValue,
                ),
            );
            canvas.drawPath(
              polygon,
              Paint()
                ..style = PaintingStyle.fill
                ..color = nextColor.withValues(alpha: opacity.doubleValue),
            );

            polygon.reset();

          // case 'star':
          //   for (var p = 0; p < localNumberOfPetals; p++) {
          //     List petalPoint = [
          //       pO[0] +
          //           stepRadius *
          //               cos(localRotate * pi +
          //                   p * pi * 2 / localNumberOfPetals),
          //       pO[1] +
          //           stepRadius *
          //               sin(localRotate * pi +
          //                   p * pi * 2 / localNumberOfPetals)
          //     ];
          //
          //     List petalMidPointA = [
          //       pO[0] +
          //           (localSquareness) *
          //               stepRadius *
          //               cos(localRotate * pi +
          //                   (p - 1) * pi * 2 / localNumberOfPetals),
          //       pO[1] +
          //           (localSquareness) *
          //               stepRadius *
          //               sin(localRotate * pi +
          //                   (p - 1) * pi * 2 / localNumberOfPetals)
          //     ];
          //
          //     List petalMidPointP = [
          //       pO[0] +
          //           (localSquareness) *
          //               stepRadius *
          //               cos(localRotate * pi +
          //                   (p + 1) * pi * 2 / localNumberOfPetals),
          //       pO[1] +
          //           (localSquareness) *
          //               stepRadius *
          //               sin(localRotate * pi +
          //                   (p + 1) * pi * 2 / localNumberOfPetals)
          //     ];
          //
          //     Path star = Path();
          //
          //     star.moveTo(pO[0], pO[1]);
          //     star.quadraticBezierTo(petalMidPointA[0], petalMidPointA[1],
          //         petalPoint[0], petalPoint[1]);
          //     star.quadraticBezierTo(
          //         petalMidPointP[0], petalMidPointP[1], pO[0], pO[1]);
          //     star.close();
          //
          //     // Choose the next colour
          //     colourOrder++;
          //     nextColor = opArt.palette.colorList[colourOrder % numberOfColors.value];
          //     if (randomColors.value) {
          //       nextColor = opArt.palette.colorList[rnd.nextInt(numberOfColors.value)];
          //     }
          //
          //     canvas.drawPath(
          //         star,
          //         Paint()
          //           ..style = PaintingStyle.stroke
          //           ..strokeWidth = lineWidth.value
          //           ..color = lineColor.value
          //               .withOpacity(opacity.value));
          //     canvas.drawPath(
          //         star,
          //         Paint()
          //           ..style = PaintingStyle.fill
          //           ..color = nextColor
          //               .withOpacity(opacity.value));
          //   }
          //
          //   break;

          case 'daisy': // daisy
            const double centreRatio = 0.3;
            final double centreRadius = stepRadius * centreRatio;

            // Choose the next colour
            colourOrder++;
            nextColor = opArt
                .palette.colorList[colourOrder % (numberOfColors.intValue)];
            if (randomColors.boolValue) {
              nextColor =
                  opArt.palette.colorList[rnd.nextInt(numberOfColors.intValue)];
            }

            canvas.drawCircle(
              Offset(pO[0], pO[1]),
              centreRadius,
              Paint()
                ..style = PaintingStyle.fill
                ..color = nextColor.withValues(alpha: opacity.doubleValue),
            );
            canvas.drawCircle(
              Offset(pO[0], pO[1]),
              centreRadius,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.doubleValue
                ..color = (lineColor.colorValue).withValues(
                  alpha: opacity.doubleValue,
                ),
            );

            for (var petal = 0; petal < localNumberOfPetals; petal++) {
              // Choose the next colour
              colourOrder++;
              nextColor = opArt
                  .palette.colorList[colourOrder % (numberOfColors.intValue)];
              if (randomColors.boolValue) {
                nextColor = opArt
                    .palette.colorList[rnd.nextInt(numberOfColors.intValue)];
              }

              final petalAngle =
                  localRotate + petal * 2 * pi / localNumberOfPetals;

              final petalCentreRadius =
                  stepRadius * (centreRatio + (1 - centreRatio) / 2);
              final petalRadius = stepRadius * ((1 - centreRatio) / 2);

              // pC = Petal centre
              final List<double> pC = [
                pO[0] + petalCentreRadius * cos(petalAngle),
                pO[1] + petalCentreRadius * sin(petalAngle),
              ];

              final List<double> pN = [
                pC[0] - petalRadius * cos(petalAngle),
                pC[1] - petalRadius * sin(petalAngle),
              ];

              final List<double> pS = [
                pC[0] - petalRadius * cos(petalAngle + pi),
                pC[1] - petalRadius * sin(petalAngle + pi),
              ];

              final List<double> pE = [
                pC[0] -
                    localSquareness * petalRadius * cos(petalAngle + pi * 0.5),
                pC[1] -
                    localSquareness * petalRadius * sin(petalAngle + pi * 0.5),
              ];

              final List<double> pW = [
                pC[0] -
                    localSquareness * petalRadius * cos(petalAngle + pi * 1.5),
                pC[1] -
                    localSquareness * petalRadius * sin(petalAngle + pi * 1.5),
              ];

              final Path path = Path();
              path.moveTo(pN[0], pN[1]);
              path.quadraticBezierTo(pE[0], pE[1], pS[0], pS[1]);
              path.quadraticBezierTo(pW[0], pW[1], pN[0], pN[1]);
              path.close();

              canvas.drawPath(
                path,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = lineWidth.doubleValue
                  ..color = (lineColor.colorValue).withValues(
                    alpha: opacity.doubleValue,
                  ),
              );
              canvas.drawPath(
                path,
                Paint()
                  ..style = PaintingStyle.fill
                  ..color = nextColor.withValues(alpha: opacity.doubleValue),
              );
            }

          case 'heart':

            // double cusp = 0.50;
            // double heartBezierPointAngle = 0.53 * pi;
            // double heartBezierPointRadiusRatio = 17.2;
            const int localNumberoOfSides = 2;
            const double heartRadiusRatio = 0.75;
            const double heartRadiusDelta = 0.25;

            final Path heart = Path();

            heart.moveTo(
              (pO[0]) +
                  (stepRadius * (heartRadiusRatio + heartRadiusDelta) +
                          cos(localRotate + pi / 2)) *
                      cos(localRotate + pi / 2),
              (pO[1]) +
                  stepRadius *
                      (heartRadiusRatio + heartRadiusDelta) *
                      sin(localRotate + pi / 2),
            );

            for (int s = 1; s <= localNumberoOfSides; s++) {
              const double t = 0.4;
              const double bezierPointRadiusDeltaA = 3.1;
              const double bezierPointRadiusDeltaB = 1.5;

              // heart.lineTo(
              //     pO[0]+ stepRadius*(heartRadiusRatio * bezierPointRadiusDelta) * cos(pi*2*t/localNumberoOfSides + localRotate + pi/2),
              //     pO[1]+ stepRadius*(heartRadiusRatio * bezierPointRadiusDelta) * sin(pi*2*t/localNumberoOfSides + localRotate + pi/2));
              //
              // heart.lineTo(
              //     pO[0]+ stepRadius*(heartRadiusRatio + heartRadiusDelta*cos(pi*2*s/localNumberoOfSides + localRotate)) * cos(pi*2*s/localNumberoOfSides + localRotate + pi/2),
              //     pO[1]+ stepRadius*(heartRadiusRatio + heartRadiusDelta*cos(pi*2*s/localNumberoOfSides + localRotate)) * sin(pi*2*s/localNumberoOfSides + localRotate + pi/2));

              if (s.isOdd) {
                heart.cubicTo(
                  (pO[0]) +
                      stepRadius *
                          (heartRadiusRatio * bezierPointRadiusDeltaA) *
                          cos(
                            pi * 2 * (s - t) / localNumberoOfSides +
                                localRotate +
                                pi / 2,
                          ),
                  (pO[1]) +
                      stepRadius *
                          (heartRadiusRatio * bezierPointRadiusDeltaA) *
                          sin(
                            pi * 2 * (s - t) / localNumberoOfSides +
                                localRotate +
                                pi / 2,
                          ),
                  (pO[0]) +
                      stepRadius *
                          (heartRadiusRatio * bezierPointRadiusDeltaB) *
                          cos(
                            pi * 2 * s / localNumberoOfSides +
                                localRotate +
                                pi / 2,
                          ),
                  (pO[1]) +
                      stepRadius *
                          (heartRadiusRatio * bezierPointRadiusDeltaB) *
                          sin(
                            pi * 2 * s / localNumberoOfSides +
                                localRotate +
                                pi / 2,
                          ),
                  (pO[0]) +
                      stepRadius *
                          (heartRadiusRatio +
                              heartRadiusDelta *
                                  cos(pi * 2 * s / localNumberoOfSides)) *
                          cos(
                            pi * 2 * s / localNumberoOfSides +
                                localRotate +
                                pi / 2,
                          ),
                  (pO[1]) +
                      stepRadius *
                          (heartRadiusRatio +
                              heartRadiusDelta *
                                  cos(pi * 2 * s / localNumberoOfSides)) *
                          sin(
                            pi * 2 * s / localNumberoOfSides +
                                localRotate +
                                pi / 2,
                          ),
                );
              } else {
                heart.cubicTo(
                  (pO[0]) +
                      stepRadius *
                          (heartRadiusRatio * bezierPointRadiusDeltaB) *
                          cos(
                            pi * 2 * (s - 1) / localNumberoOfSides +
                                localRotate +
                                pi / 2,
                          ),
                  (pO[1]) +
                      stepRadius *
                          (heartRadiusRatio * bezierPointRadiusDeltaB) *
                          sin(
                            pi * 2 * (s - 1) / localNumberoOfSides +
                                localRotate +
                                pi / 2,
                          ),
                  (pO[0]) +
                      stepRadius *
                          (heartRadiusRatio * bezierPointRadiusDeltaA) *
                          cos(
                            pi * 2 * (s - 1 + t) / localNumberoOfSides +
                                localRotate +
                                pi / 2,
                          ),
                  (pO[1]) +
                      stepRadius *
                          (heartRadiusRatio * bezierPointRadiusDeltaA) *
                          sin(
                            pi * 2 * (s - 1 + t) / localNumberoOfSides +
                                localRotate +
                                pi / 2,
                          ),
                  (pO[0]) +
                      stepRadius *
                          (heartRadiusRatio +
                              heartRadiusDelta *
                                  cos(pi * 2 * s / localNumberoOfSides)) *
                          cos(
                            pi * 2 * s / localNumberoOfSides +
                                localRotate +
                                pi / 2,
                          ),
                  (pO[1]) +
                      stepRadius *
                          (heartRadiusRatio +
                              heartRadiusDelta *
                                  cos(pi * 2 * s / localNumberoOfSides)) *
                          sin(
                            pi * 2 * s / localNumberoOfSides +
                                localRotate +
                                pi / 2,
                          ),
                );
              }
            }

            heart.close();

            // Path heart = Path();
            //
            // heart.moveTo(
            //     pO[0]+ stepRadius * cos(localRotate + pi/2),
            //     pO[1]+ stepRadius * sin(localRotate + pi/2));

            // heart.lineTo(
            //     pO[0]+ stepRadius * heartBezierPointRadiusRatio * cos(localRotate + pi*2 + heartBezierPointAngle),
            //     pO[1]+ stepRadius * heartBezierPointRadiusRatio * sin(localRotate + pi/2 + heartBezierPointAngle));
            //
            // heart.lineTo(
            //     pO[0]+ stepRadius * cusp * cos(localRotate + pi*3/2),
            //     pO[1]+ stepRadius * cusp * sin(localRotate + pi*3/2));
            //
            // heart.lineTo(
            //   pO[0]- stepRadius * heartBezierPointRadiusRatio * cos(localRotate + pi*2 + heartBezierPointAngle),
            //   pO[1]+ stepRadius * heartBezierPointRadiusRatio * sin(localRotate + pi/2 + heartBezierPointAngle));
            //
            // heart.lineTo(
            //   pO[0]+ stepRadius * cos(localRotate + pi/2),
            //   pO[1]+ stepRadius * sin(localRotate + pi/2));

            //
            // heart.quadraticBezierTo(
            //     pO[0]+ stepRadius * heartBezierPointRadiusRatio * cos(localRotate + pi*2 + heartBezierPointAngle),
            //     pO[1]+ stepRadius * heartBezierPointRadiusRatio * sin(localRotate + pi/2 + heartBezierPointAngle),
            //     pO[0]+ stepRadius * cusp * cos(localRotate + pi*3/2),
            //     pO[1]+ stepRadius * cusp * sin(localRotate + pi*3/2));
            //
            // heart.quadraticBezierTo(
            //     pO[0]- stepRadius * heartBezierPointRadiusRatio * cos(localRotate + pi*2 + heartBezierPointAngle),
            //     pO[1]+ stepRadius * heartBezierPointRadiusRatio * sin(localRotate + pi/2 + heartBezierPointAngle),
            //     pO[0]+ stepRadius * cos(localRotate + pi/2),
            //     pO[1]+ stepRadius * sin(localRotate + pi/2));
            //
            // heart.close();

            // Choose the next colour
            colourOrder++;
            nextColor = opArt
                .palette.colorList[colourOrder % (numberOfColors.intValue)];
            if (randomColors.boolValue) {
              nextColor =
                  opArt.palette.colorList[rnd.nextInt(numberOfColors.intValue)];
            }

            canvas.drawPath(
              heart,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.doubleValue
                ..color = (lineColor.colorValue).withValues(
                  alpha: opacity.doubleValue,
                ),
            );
            canvas.drawPath(
              heart,
              Paint()
                ..style = PaintingStyle.fill
                ..color = nextColor.withValues(alpha: opacity.doubleValue),
            );

            heart.reset();
        }

        // Drift & Rotate

        if ((alternateDrift.boolValue) && (i + j).isEven) {
          localRotate = localRotate - (rotateStep.numValue);
        } else {
          localRotate = localRotate + (rotateStep.numValue);
        }

        if ((alternateDrift.boolValue) && i.isEven) {
          dX = dX - (driftX.numValue);
        } else {
          dX = dX + (driftX.numValue);
        }
        if ((alternateDrift.boolValue) && j.isEven) {
          dY = dY - (driftY.numValue);
        } else {
          dY = dY + (driftY.numValue);
        }

        stepRadius = stepRadius - localStep;
        k++;
      } while (k < 40 && stepRadius > 0 && (step.numValue) > 0);
    }
  }
}
