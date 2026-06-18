import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:opart_v2/app_state.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/model_palette.dart';
import 'package:opart_v2/model_settings.dart';

// List<String> list = [];

List<List<Color>> squaresI = [];
double? _lastLifeAnimationVariable;
OpArt? _lastLifeOpArt;

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
    squaresI = [];
    _lastLifeAnimationVariable = null;
  },
  silent: true,
);

SettingsModel zoomOpArt = SettingsModel(
  name: 'zoomOpArt',
  settingType: SettingType.double,
  label: 'Zoom',
  tooltip: 'Zoom in and out',
  min: 1.0,
  max: 50.0,
  zoom: 100,
  defaultValue: 5.0,
  icon: const Icon(Icons.zoom_in),
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

List<SettingsModel> initializeLifeAttributes() {
  return [
    reDraw,
    zoomOpArt,
    randomColors,
    numberOfColors,
    paletteType,
    paletteList,
    opacity,
    resetDefaults,
  ];
}

void _drawLifeGrid(
  Canvas canvas,
  int cellsX,
  int cellsY,
  double borderX,
  double borderY,
  List<List<Color>> grid,
) {
  final double cellSize = zoomOpArt.doubleValue;
  for (int i = 0; i < cellsX; ++i) {
    for (int j = 0; j < cellsY; ++j) {
      final x = borderX + i * cellSize;
      final y = borderY + j * cellSize;
      canvas.drawRect(
        Offset(x, y) & Size(cellSize, cellSize),
        Paint()
          ..strokeWidth = 0.0
          ..color = grid[i][j]
          ..isAntiAlias = false
          ..style = PaintingStyle.fill,
      );
    }
  }
}

List<List<Color>> _createInitialLifeGrid(
  int cellsX,
  int cellsY,
  Random rnd,
) {
  final List<List<Color>> grid = [];
  for (int i = 0; i < cellsX; ++i) {
    final List<Color> row = [];
    for (int j = 0; j < cellsY; ++j) {
      row.add(
        Color.fromRGBO(
          rnd.nextDouble() > 0.65 ? rnd.nextInt(156) + 100 : 0,
          rnd.nextDouble() > 0.65 ? rnd.nextInt(156) + 100 : 0,
          rnd.nextDouble() > 0.65 ? rnd.nextInt(156) + 100 : 0,
          1,
        ),
      );
    }
    grid.add(row);
  }
  return grid;
}

void paintLife(
  Canvas canvas,
  Size size,
  int seed,
  double animationVariable,
  OpArt opArt,
) {
  if (_lastLifeOpArt != opArt) {
    _lastLifeOpArt = opArt;
    squaresI = [];
    _lastLifeAnimationVariable = null;
  }

  rnd = Random(seed);

  if (paletteList.value != opArt.palette.paletteName) {
    opArt.selectPalette(paletteList.stringValue);
  }

  // Initialise the canvas
  final double canvasWidth = size.width;
  final double canvasHeight = size.height;
  double borderX = 0;
  double borderY = 0;

  // Work out the X and Y
  final int cellsX =
      (canvasWidth / (zoomOpArt.doubleValue) + 1.9999999).toInt();
  borderX = (canvasWidth - (zoomOpArt.doubleValue) * cellsX) / 2;

  final int cellsY =
      (canvasHeight / (zoomOpArt.doubleValue) + 1.9999999).toInt();
  borderY = (canvasHeight - (zoomOpArt.doubleValue) * cellsY) / 2;
  borderY = (canvasHeight - (zoomOpArt.doubleValue) * cellsY) / 2;

  final bool gridNeedsInit = squaresI.isEmpty ||
      squaresI.length != cellsX ||
      squaresI[0].length != cellsY;
  final bool shouldEvolve =
      gridNeedsInit || _lastLifeAnimationVariable != animationVariable;

  if (gridNeedsInit) {
    squaresI = _createInitialLifeGrid(cellsX, cellsY, Random(seed));
    _lastLifeAnimationVariable = animationVariable;
    _drawLifeGrid(canvas, cellsX, cellsY, borderX, borderY, squaresI);
    return;
  }

  if (!shouldEvolve) {
    _drawLifeGrid(canvas, cellsX, cellsY, borderX, borderY, squaresI);
    return;
  }

  _lastLifeAnimationVariable = animationVariable;

  final List<List<Color>> oldSquaresI = squaresI;
  squaresI = [];

  //play the game
  for (int i = 0; i < cellsX; ++i) {
    final List<Color> squaresJ = [];

    for (int j = 0; j < cellsY; ++j) {
      final List<Color> neighbours = [];

      // if (i>0 && j>0) neighbours.add(oldSquaresI[i-1][j-1]);
      // if (i>0 && j<cellsY-1) neighbours.add(oldSquaresI[i-1][j+1]);
      // if (i<cellsX-1 && j>0) neighbours.add(oldSquaresI[i+1][j-1]);
      // if (i<cellsX-1 && j<cellsY-1) neighbours.add(oldSquaresI[i+1][j+1]);

      if (i > 0) neighbours.add(oldSquaresI[i - 1][j]);
      if (j > 0) neighbours.add(oldSquaresI[i][j - 1]);
      if (i < cellsX - 1) neighbours.add(oldSquaresI[i + 1][j]);
      if (j < cellsY - 1) neighbours.add(oldSquaresI[i][j + 1]);

      int neighboursRed = 0;
      int neighboursGreen = 0;
      int neighboursBlue = 0;

      for (int n = 0; n < neighbours.length; n++) {
        if (neighbours[n].r > 0) neighboursRed++;
        if (neighbours[n].g > 0) neighboursGreen++;
        if (neighbours[n].b > 0) neighboursBlue++;
      }

      // Any live cell with fewer than two live neighbours dies, as if by underpopulation.
      // Any live cell with two or three live neighbours lives on to the next generation.
      // Any live cell with more than three live neighbours dies, as if by overpopulation.
      // Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

      final bool wasAliveRed = oldSquaresI[i][j].r * 255 > 100;
      final bool nowAliveRed =
          wasAliveRed && (neighboursRed == 2 || neighboursRed == 3) ||
              (!wasAliveRed && neighboursRed == 3);
      final bool wasAliveGreen = oldSquaresI[i][j].g * 255 > 100;
      final bool nowAliveGreen =
          wasAliveGreen && (neighboursGreen == 2 || neighboursGreen == 3) ||
              (!wasAliveGreen && neighboursGreen == 3);
      final bool wasAliveBlue = oldSquaresI[i][j].b * 255 > 100;
      final bool nowAliveBlue =
          wasAliveBlue && (neighboursBlue == 2 || neighboursBlue == 3) ||
              (!wasAliveBlue && neighboursBlue == 3);

      final Color nextColor = Color.fromRGBO(
        nowAliveRed ? rnd.nextInt(156) + 100 : 0,
        nowAliveGreen ? rnd.nextInt(156) + 100 : 0,
        nowAliveBlue ? rnd.nextInt(156) + 100 : 0,
        1,
      );

      squaresJ.add(nextColor);
    }
    squaresI.add(squaresJ);
  }

  _drawLifeGrid(canvas, cellsX, cellsY, borderX, borderY, squaresI);
}
