import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:opart_v2/app_state.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/model_palette.dart';
import 'package:opart_v2/model_settings.dart';

List<Color> shades = [];
List<List<double>> cells = [];
List<Color> colorList = [];
int shadeOffset = 0;
int recursionDepthOld = 0;
double randomizerOld = 0.0;
OpArt? _lastPlasmaOpArt;
double? _lastPlasmaAnimationVariable;

SettingsModel reDraw = SettingsModel(
  name: 'reDraw',
  settingType: SettingType.button,
  label: 'Redraw',
  tooltip: 'Re-draw the picture with a different random seed',
  defaultValue: false,
  randomTrue: 1.0,
  icon: const Icon(Icons.refresh),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  onChange: () {
    seed = DateTime.now().millisecond;
  },
  silent: true,
);

SettingsModel recursionDepth = SettingsModel(
  settingType: SettingType.int,
  name: 'recursionDepth',
  label: 'Recursion Depth',
  tooltip: 'The recursion depth',
  min: 2,
  max: 8,
  zoom: 100,
  defaultValue: 8,
  icon: const Icon(Icons.file_download),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel colorDepth = SettingsModel(
  settingType: SettingType.int,
  name: 'colorDepth',
  label: 'Color Depth',
  tooltip: 'Sets the colorDepth.valueness of the colors',
  min: 1,
  max: 100,
  zoom: 100,
  defaultValue: 10,
  icon: const Icon(Icons.line_weight),
  settingCategory: SettingCategory.palette,
  proFeature: false,
);

SettingsModel randomizer = SettingsModel(
  name: 'randomizer',
  settingType: SettingType.double,
  label: 'Randomizer',
  tooltip: 'The amount of randomness in the plasma',
  min: 0.0,
  max: 0.5,
  randomMin: 0.05,
  randomMax: 0.35,
  zoom: 100,
  defaultValue: 0.1,
  icon: const Icon(Icons.remove_red_eye),
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

List<SettingsModel> initializePlasmaAttributes() {
  return [
    reDraw,
    recursionDepth,
    colorDepth,
    randomizer,
    numberOfColors,
    paletteType,
    paletteList,
    opacity,
    resetDefaults,
  ];
}

void paintPlasma(
  Canvas canvas,
  Size size,
  int seed,
  double animationVariable,
  OpArt opArt,
) {
  rnd = Random(seed);

  if (_lastPlasmaOpArt != opArt) {
    _lastPlasmaOpArt = opArt;
    _lastPlasmaAnimationVariable = null;
    shadeOffset = 0;
  }

  if (paletteList.value != opArt.palette.paletteName) {
    opArt.selectPalette(paletteList.stringValue);
  }

  if (reDraw.boolValue ||
      colorList != opArt.palette.colorList ||
      shades.length !=
          (opArt.palette.colorList.length) * (colorDepth.numValue)) {
    // generate the palette
    shadeOffset = 0;
    _lastPlasmaAnimationVariable = null;
    colorList = opArt.palette.colorList;

    final int numberOfColors = opArt.palette.colorList.length;
    final int numberOfShades = numberOfColors * (colorDepth.intValue);
    shades = List.filled(numberOfShades, Colors.black);
    shades[0] = opArt.palette.colorList[0];
    for (int i = 0; i < numberOfColors; i++) {
      for (int j = 0; j < (colorDepth.numValue); j++) {
        shades[i * colorDepth.intValue + j] = Color.lerp(
          opArt.palette.colorList[i],
          opArt.palette.colorList[(i + 1) % numberOfColors],
          j / colorDepth.numValue,
        )!;
      }
    }
  }

  if (reDraw.boolValue ||
      recursionDepthOld != recursionDepth.value ||
      randomizerOld != randomizer.value) {
    recursionDepthOld = recursionDepth.intValue;
    randomizerOld = randomizer.doubleValue;
    _lastPlasmaAnimationVariable = null;
    shadeOffset = 0;

    // reseed - otherwise it's boring
    rnd = Random(DateTime.now().millisecond);

    // generate the plasma

    // create the grid
    final int numberOfCells = pow(2, recursionDepth.numValue) as int;
    // print('numberOfCells: $numberOfCells');

    cells = List.generate(
      numberOfCells + 1,
      (_) => List<double>.filled(numberOfCells + 1, 0.0),
    );

    // populate the corners
    cells[0][0] = rnd.nextDouble();
    cells[0][numberOfCells] = rnd.nextDouble();
    cells[numberOfCells][0] = rnd.nextDouble();
    cells[numberOfCells][numberOfCells] = rnd.nextDouble();

    for (int d = numberOfCells; d > 1; d = d ~/ 2) {
      for (int i = d ~/ 2; i <= numberOfCells; i = i + d) {
        for (int j = d ~/ 2; j <= numberOfCells; j = j + d) {
          square(i, j, d ~/ 2, randomizer.doubleValue, numberOfCells);
        }
      }
      for (int i = d ~/ 2; i <= numberOfCells; i = i + d) {
        for (int j = d ~/ 2; j <= numberOfCells; j = j + d) {
          diamond(i, j - d ~/ 2, d ~/ 2, randomizer.doubleValue, numberOfCells);
          diamond(i, j + d ~/ 2, d ~/ 2, randomizer.doubleValue, numberOfCells);
          diamond(i - d ~/ 2, j, d ~/ 2, randomizer.doubleValue, numberOfCells);
          diamond(i + d ~/ 2, j, d ~/ 2, randomizer.doubleValue, numberOfCells);
        }
      }
    }
  }

  // Initialise the canvas
  final int numberOfCells = pow(2, recursionDepth.numValue) as int;
  final double cellWidth = size.width / (numberOfCells + 1);
  final double cellHeight = size.height / (numberOfCells + 1);

  // Now make some art
  for (int i = 0; i <= numberOfCells; ++i) {
    for (int j = 0; j <= numberOfCells; ++j) {
      final List<double> p1 = [i * cellWidth, j * cellHeight];

      // print('i: $i j: $j cells[i][j]: ${cells[i][j]} shades.length: ${shades.length} shades[ (shadeOffset + (cells[i][j]*shades.length).toInt()) % shades.length]: ${shades[ (shadeOffset + (cells[i][j]*shades.length).toInt()) % shades.length]}');

      final Color nextColor = shades[
          (shadeOffset + ((cells[i][j] as num) * shades.length).toInt()) %
              shades.length];

      // draw the square
      canvas.drawRect(
        Offset(p1[0], p1[1]) & Size(cellWidth, cellHeight),
        Paint()
          ..strokeWidth = 0.0
          ..color = nextColor
          ..isAntiAlias = false
          ..style = PaintingStyle.fill,
      );
    }
  }

  if (_lastPlasmaAnimationVariable != animationVariable) {
    if (_lastPlasmaAnimationVariable != null) {
      shadeOffset++;
    } else if (animationVariable > 0 && shades.isNotEmpty) {
      shadeOffset = (animationVariable * shades.length * 50).toInt();
    }
    _lastPlasmaAnimationVariable = animationVariable;
  }
}

// fill the centre of the square
void square(int x, int y, int width, double randomizer, int numberOfCells) {
  // print('square x: $x y: $y width: $width randomizer: $randomizer numberOfCells: $numberOfCells');

  final double fill = (cells[x - width][y - width] +
              cells[x - width][y + width] +
              cells[x + width][y - width] +
              cells[x + width][y + width]) /
          4 +
      rnd.nextDouble() * randomizer -
      randomizer / 2;

  cells[x][y] = (fill > 1)
      ? 1
      : (fill < 0)
          ? 0
          : fill;
}

// fill the centre of the diamond
void diamond(int x, int y, int width, double randomizer, int numberOfCells) {
  final double fill = (cells[(x + width <= numberOfCells)
                  ? x + width
                  : x + width - numberOfCells][y] +
              cells[(x - width >= 0) ? x - width : x - width + numberOfCells]
                  [y] +
              cells[x][(y + width <= numberOfCells)
                  ? y + width
                  : y + width - numberOfCells] +
              cells[x]
                  [(y - width >= 0) ? y - width : y - width + numberOfCells]) /
          4 +
      rnd.nextDouble() * randomizer -
      randomizer / 2;

  cells[x][y] = (fill > 1)
      ? 1
      : (fill < 0)
          ? 0
          : fill;
}
