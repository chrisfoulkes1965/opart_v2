import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opart_v2/opart_icons.dart';

import 'package:opart_v2/app_state.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/model_palette.dart';
import 'package:opart_v2/model_settings.dart';

List<String> list = [];

SettingsModel zoomOpArt = SettingsModel(
  name: 'zoomOpArt',
  settingType: SettingType.double,
  label: 'Radius',
  tooltip: 'The radius of the shapes',
  min: 10.0,
  max: 200.0,
  zoom: 100,
  defaultValue: 30.0,
  icon: const Icon(Icons.zoom_in),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel shape = SettingsModel(
  name: 'shape',
  settingType: SettingType.list,
  label: 'Shape',
  tooltip: 'The shape in the cell',
  defaultValue: 'circle',
  icon: const Icon(Icons.settings),
  options: ['circle', 'square', 'squaricle'],
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel step = SettingsModel(
  name: 'step',
  settingType: SettingType.double,
  label: 'Step',
  tooltip: 'The decrease ratio of concentric shapes',
  min: 0.05,
  max: 0.80,
  zoom: 100,
  defaultValue: 0.05,
  icon: const Icon(Icons.control_point),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel amplitude = SettingsModel(
  name: 'amplitude',
  settingType: SettingType.double,
  label: 'Amplitude',
  tooltip: 'The amplitude of the wave',
  min: 0.0,
  max: 100.0,
  zoom: 100,
  defaultValue: 15.0,
  icon: const Icon(Icons.control_point),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel frequency = SettingsModel(
  name: 'frequency',
  settingType: SettingType.double,
  label: 'Frequency',
  tooltip: 'The frequency of concentric the wave',
  min: 0.0,
  max: 200.0,
  zoom: 100,
  defaultValue: 70.0,
  icon: const Icon(Icons.control_point),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel ratio = SettingsModel(
  name: 'ratio',
  settingType: SettingType.double,
  label: 'Ratio',
  tooltip: 'The ratio of the shape to the box',
  min: 0.25,
  max: 1.0,
  zoom: 100,
  defaultValue: 1.0,
  icon: const Icon(OpArtLab.wallpaperRatio),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel box = SettingsModel(
  name: 'box',
  settingType: SettingType.bool,
  label: 'Box',
  tooltip: 'Fill in the box',
  defaultValue: false,
  icon: const Icon(Icons.check_box_outline_blank),
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
  defaultValue: true,
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

List<SettingsModel> initializeFlowAttributes() {
  return [
    zoomOpArt,
    shape,
    step,
    ratio,
    amplitude,
    frequency,
    box,
    squareness,
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

void paintFlow(
    Canvas canvas, Size size, int seed, double animationVariable, OpArt opArt) {
  rnd = Random(seed);

  if (paletteList.value != opArt.palette.paletteName) {
    opArt.selectPalette(paletteList.value as String);
  }

  // Initialise the canvas
  final double canvasWidth = size.width;
  final double canvasHeight = size.height;

  // colour in the canvas
  canvas.drawRect(
      const Offset(0, 0) & Size(canvasWidth, canvasHeight),
      Paint()
        ..color = backgroundColor.value as Color
        ..style = PaintingStyle.fill);

  // Work out the X and Y
  // int cellsX = (canvasWidth / (zoomOpArt.value * squeezeX.value)+1.9999999).toInt();
  // borderX = (canvasWidth - zoomOpArt.value * squeezeX.value * cellsX) / 2;
  //
  // int cellsY = (canvasHeight / (zoomOpArt.value * squeezeY.value)+1.9999999).toInt();
  // borderY = (canvasHeight - zoomOpArt.value * squeezeY.value * cellsY) / 2;

  int colourOrder = 0;

  // Now make some art

  // fill
  // bool fill = true;

  // int extraCellsX = 0;
  // int extraCellsY = 0;
  // if (fill) {
  //   extraCellsX = (cellsX * 2 ~/ squeezeX.value);
  //   extraCellsY = (cellsY * 2 ~/ squeezeY.value);
  // }

  // work out the radius from the width and the cells
  // double radius = zoomOpArt.value / 2;

  // double localSquareness = sin(2500 * animationVariable);
  // double localSquareness = squareness.value;

  final double baseX = zoomOpArt.value as double;
  final double amplitudeX =
      ((amplitude.value as double) < (zoomOpArt.value as double) * 0.9)
          ? (amplitude.value as double)
          : (zoomOpArt.value as double) * 0.9;
  final double frequencyX = frequency.value as double;

  final double baseY = baseX * 1.0;
  final double amplitudeY =
      ((amplitude.value as double) < (zoomOpArt.value as double) * 0.9)
          ? (amplitude.value as double)
          : (zoomOpArt.value as double) * 0.9;
  final double frequencyY = frequency.value as double;

  double x = 0.0;
  int i = 0;

  // print(animationVariable);

  do {
    final double deltaX =
        baseX + amplitudeX * cos(4000 * animationVariable + x / frequencyX);

    // reset the colours
    Color nextColor;
    if (resetColors.value as bool) {
      colourOrder = i;
    }

    double y = 0.0;
    int j = 0;

    do {
      final double deltaY = baseY +
          amplitudeY * cos(4000 * animationVariable + (x + y) / frequencyY);
// print('animationVariable: $animationVariable deltaX: $deltaX deltaY: $deltaY');

      double stepRatio = ratio.value as double;
      int k = 0; // count the steps

      // Centre of the square
      final List pO = [x + deltaX / 2, y + deltaY / 2];

      if (box.value as bool) {
        // Choose the next colour
        colourOrder++;
        nextColor = opArt
            .palette.colorList[colourOrder % (numberOfColors.value as int)];
        if (randomColors.value as bool) {
          nextColor =
              opArt.palette.colorList[rnd.nextInt(numberOfColors.value as int)];
        }

        // fill the square
        canvas.drawRect(
            Rect.fromLTRB(x, y, x + deltaX, y + deltaY),
            Paint()
              ..style = PaintingStyle.fill
              ..color = nextColor.withOpacity(opacity.value as double));
      }

      do {
        switch (shape.value as String) {
          case 'circle':

            // Choose the next colour
            colourOrder++;
            nextColor = opArt
                .palette.colorList[colourOrder % (numberOfColors.value as int)];
            if (randomColors.value as bool) {
              nextColor = opArt
                  .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
            }

            canvas.drawOval(
                Rect.fromLTRB(
                  pO[0] - deltaX / 2 * stepRatio as double,
                  pO[1] - deltaY / 2 * stepRatio as double,
                  pO[0] + deltaX / 2 * stepRatio as double,
                  pO[1] + deltaY / 2 * stepRatio as double,
                ),
                Paint()
                  ..style = PaintingStyle.fill
                  ..color = nextColor.withOpacity(opacity.value as double));
            canvas.drawOval(
                Rect.fromLTRB(
                  pO[0] - deltaX / 2 * stepRatio as double,
                  pO[1] - deltaY / 2 * stepRatio as double,
                  pO[0] + deltaX / 2 * stepRatio as double,
                  pO[1] + deltaY / 2 * stepRatio as double,
                ),
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = lineWidth.value as double
                  ..color = (lineColor.value as Color)
                      .withOpacity(opacity.value as double));


          case 'square':

            // Choose the next colour
            colourOrder++;
            nextColor = opArt
                .palette.colorList[colourOrder % (numberOfColors.value as int)];
            if (randomColors.value as bool) {
              nextColor = opArt
                  .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
            }

            canvas.drawRect(
                Rect.fromLTRB(
                    pO[0] - deltaX / 2 * stepRatio as double,
                    pO[1] - deltaY / 2 * stepRatio as double,
                    pO[0] + deltaX / 2 * stepRatio as double,
                    pO[1] + deltaY / 2 * stepRatio as double),
                Paint()
                  ..style = PaintingStyle.fill
                  ..color = nextColor.withOpacity(opacity.value as double));
            canvas.drawRect(
              Rect.fromLTRB(
                  pO[0] - deltaX / 2 * stepRatio as double,
                  pO[1] - deltaY / 2 * stepRatio as double,
                  pO[0] + deltaX / 2 * stepRatio as double,
                  pO[1] + deltaY / 2 * stepRatio as double),
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = lineWidth.value as double
                ..color = (lineColor.value as Color)
                    .withOpacity(opacity.value as double),
            );

          case 'squaricle':
            final double radius = (deltaX < deltaY)
                ? stepRatio * deltaX / 2 * (1 - (squareness.value as double)) -
                    (lineWidth.value as double) / 2
                : stepRatio * deltaY / 2 * (1 - (squareness.value as double)) -
                    (lineWidth.value as double) / 2;

            final Path squaricle = Path();

            squaricle.arcTo(
                Rect.fromCenter(
                    center: Offset(
                      pO[0] - deltaX / 2 * stepRatio + radius as double,
                      pO[1] - deltaY / 2 * stepRatio + radius as double,
                    ),
                    height: radius,
                    width: radius),
                pi * (2 / 2),
                pi / 2,
                false);

            squaricle.arcTo(
                Rect.fromCenter(
                    center: Offset(
                      pO[0] + deltaX / 2 * stepRatio - radius as double,
                      pO[1] - deltaY / 2 * stepRatio + radius as double,
                    ),
                    height: radius,
                    width: radius),
                pi * (3 / 2),
                pi / 2,
                false);

            squaricle.arcTo(
                Rect.fromCenter(
                    center: Offset(
                      pO[0] + deltaX / 2 * stepRatio - radius as double,
                      pO[1] + deltaY / 2 * stepRatio - radius as double,
                    ),
                    height: radius,
                    width: radius),
                pi * (0 / 2),
                pi / 2,
                false);

            squaricle.arcTo(
                Rect.fromCenter(
                    center: Offset(
                      pO[0] - deltaX / 2 * stepRatio + radius as double,
                      pO[1] + deltaY / 2 * stepRatio - radius as double,
                    ),
                    height: radius,
                    width: radius),
                pi * (1 / 2),
                pi / 2,
                false);

            squaricle.close();

            // Choose the next colour
            colourOrder++;
            nextColor = opArt
                .palette.colorList[colourOrder % (numberOfColors.value as int)];
            if (randomColors.value as bool) {
              nextColor = opArt
                  .palette.colorList[rnd.nextInt(numberOfColors.value as int)];
            }

            canvas.drawPath(
                squaricle,
                Paint()
                  ..style = PaintingStyle.fill
                  ..color = nextColor.withOpacity(opacity.value as double));
            canvas.drawPath(
                squaricle,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = lineWidth.value as double
                  ..color = (lineColor.value as Color)
                      .withOpacity(opacity.value as double));

            squaricle.reset();

        }

        stepRatio = stepRatio * (step.value as num);

        k++;
      } while (k < 10 && stepRatio > 0.1);

      j++;
      y = y + deltaY;
    } while (y < canvasHeight); // while y

    i++;
    x = x + deltaX;
  } while (x < canvasWidth); // while x
}
