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
  min: 0.2,
  max: 4.0,
  zoom: 100,
  defaultValue: 2.0,
  icon: const Icon(Icons.zoom_in),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel irisRadius = SettingsModel(
  name: 'irisRadius',
  settingType: SettingType.double,
  label: 'Iris Radius',
  tooltip: 'The radius of the iris of the eye',
  min: 0.0,
  max: 150.0,
  randomMax: 10.0,
  randomMin: 30.0,
  zoom: 100,
  defaultValue: 30.0,
  icon: const Icon(Icons.adjust),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel numberOfTrees = SettingsModel(
  name: 'numberOfTrees',
  settingType: SettingType.int,
  label: 'Number of spokes',
  tooltip: 'The number of spokes radiating from the iris',
  min: 5,
  max: 50,
  randomMin: 5,
  randomMax: 30,
  defaultValue: 20,
  icon: const Icon(Icons.filter_tilt_shift),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel trunkWidth = SettingsModel(
  name: 'trunkWidth',
  settingType: SettingType.double,
  label: 'Trunk Width',
  tooltip: 'The width of the base of the trunk',
  min: 0.0,
  max: 10.0,
  zoom: 100,
  defaultValue: 2.0,
  icon: const Icon(Icons.track_changes),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);
SettingsModel widthDecay = SettingsModel(
  name: 'widthDecay',
  settingType: SettingType.double,
  label: 'Trunk Decay',
  tooltip: 'The rate at which the trunk width decays',
  min: 0.7,
  max: 1.0,
  randomMin: 0.7,
  randomMax: 0.9,
  zoom: 100,
  defaultValue: 0.8,
  icon: const Icon(Icons.swap_horiz),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);
SettingsModel segmentLength = SettingsModel(
  name: 'segmentLength',
  settingType: SettingType.double,
  label: 'Segment Length',
  tooltip: 'The length of the first segment of the trunk',
  min: 10.0,
  max: 100.0,
  randomMin: 5.0,
  randomMax: 30.0,
  zoom: 100,
  defaultValue: 10.0,
  icon: const Icon(Icons.swap_horizontal_circle),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel segmentDecay = SettingsModel(
  name: 'segmentDecay',
  settingType: SettingType.double,
  label: 'Segment Decay',
  tooltip: 'The rate at which the length of each successive segment decays',
  min: 0.1,
  max: 1.0,
  randomMin: 0.8,
  randomMax: 0.95,
  zoom: 100,
  defaultValue: 0.92,
  icon: const Icon(Icons.swap_vert),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel branch = SettingsModel(
  name: 'branch',
  settingType: SettingType.double,
  label: 'Branch Ratio',
  tooltip: 'The proportion of segments that branch',
  min: 0.0,
  max: 1.0,
  randomMin: 0.4,
  randomMax: 0.8,
  zoom: 100,
  defaultValue: 0.7,
  icon: const Icon(Icons.ac_unit),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);
SettingsModel angle = SettingsModel(
  name: 'angle',
  settingType: SettingType.double,
  label: 'Branch Angle',
  tooltip: 'The angle of the branch',
  min: 0.1,
  max: 0.7,
  zoom: 100,
  defaultValue: 0.3,
  icon: const Icon(Icons.rotate_right),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);
SettingsModel ratio = SettingsModel(
  name: 'ratio',
  settingType: SettingType.double,
  label: 'Angle Ratio',
  tooltip: 'The ratio of the branch',
  min: 0.0,
  max: 1.0,
  zoom: 100,
  defaultValue: 0.5,
  icon: const Icon(Icons.blur_circular),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);
SettingsModel maxDepth = SettingsModel(
  name: 'maxDepth',
  settingType: SettingType.int,
  label: 'Max Depth',
  tooltip: 'The number of segments',
  min: 5,
  max: 15,
  randomMin: 5,
  randomMax: 10,
  defaultValue: 10,
  icon: const Icon(Icons.fiber_smart_record),
  settingCategory: SettingCategory.tool,
  proFeature: false,
);

SettingsModel trunkFillColor = SettingsModel(
  settingType: SettingType.color,
  name: 'trunkFillColor',
  label: 'Trunk Color',
  tooltip: 'The fill colour of the trunk',
  defaultValue: Colors.black87,
  icon: const Icon(Icons.settings_overscan),
  settingCategory: SettingCategory.palette,
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
  options: <String>[
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
  settingCategory: SettingCategory.palette,
  proFeature: false,
);

SettingsModel colorDecay = SettingsModel(
  name: 'colorDecay',
  settingType: SettingType.double,
  label: 'Color Decay',
  tooltip:
      'The rate at which the color of each successive segment changes from the core color',
  min: 0.1,
  max: 1.0,
  randomMin: 0.3,
  randomMax: 1.0,
  zoom: 100,
  defaultValue: 0.8,
  icon: const Icon(Icons.track_changes),
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
  proFeature: false,
  onChange: () {
    resetAllDefaults();
  },
  silent: true,
);

List<SettingsModel> initializeEyeAttributes() {
  return [
    reDraw,
    zoomOpArt,
    irisRadius,
    numberOfTrees,
    trunkWidth,
    widthDecay,
    segmentLength,
    segmentDecay,
    branch,
    angle,
    ratio,
    maxDepth,
    backgroundColor,
    numberOfColors,
    trunkFillColor,
    paletteType,
    paletteList,
    opacity,
    colorDecay,
    randomColors,
    resetDefaults,
  ];
}

void paintEye(
    Canvas canvas, Size size, int seed, double animationVariable, OpArt opArt) {
  rnd = Random(seed);

  if (paletteList.value != opArt.palette.paletteName) {
    opArt.selectPalette(paletteList.value as String);
  }

  // colour in the canvas
  canvas.drawRect(
      const Offset(0, 0) & Size(size.width, size.height),
      Paint()
        ..color = backgroundColor.value as Color
        ..style = PaintingStyle.fill);

  for (int t = 0; t < (numberOfTrees.value as int); t++) {
    final double treeAngle = t * 2 * pi / (numberOfTrees.value as num);
    final List treeBase = [
      size.width / 2 + (irisRadius.value as num) * cos(treeAngle),
      size.height / 2 - (irisRadius.value as num) * sin(treeAngle)
    ];

    drawSegment(
        canvas,
        rnd,
        0,
        0,
        treeBase,
        (trunkWidth.value as double) * (zoomOpArt.value as double),
        segmentLength.value * zoomOpArt.value as double,
        treeAngle,
        ratio.value as double,
        0,
        false,
        animationVariable,
        branch.value as double,
        angle.value as double,
        widthDecay.value as double,
        segmentDecay.value as double,
        maxDepth.value as int,
        trunkFillColor.value as Color,
        opacity.value as double,
        colorDecay.value as double,
        1.0,
        numberOfColors.value.toInt() as int,
        opArt.palette.colorList,
        0,
        randomColors.value as bool);
  }

  canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      irisRadius.value as double,
      Paint()
        ..style = PaintingStyle.fill
        ..color = (trunkFillColor.value as Color)
            .withOpacity(opacity.value as double));
}

void drawSegment(
  Canvas canvas,
  Random rnd,
  double borderX,
  double borderY,
  List root,
  double width,
  double segmentLength,
  double direction,
  double ratio,
  int currentDepth,
  bool justBranched,
  double animationVariable,
  double branch,
  double angle,
  double widthDecay,
  double segmentDecay,
  int maxDepth,
  Color trunkFillColor,
  double opacity,
  double colorDecay,
  double colorRatio,
  int numberOfColors,
  List palette,
  int colourOrder,
  bool randomColors,
) {
  if (currentDepth < maxDepth) {
    // Choose the next colour
    colourOrder++;
    Color nextColor = palette[colourOrder % numberOfColors] as Color;
    if (randomColors) {
      nextColor = palette[rnd.nextInt(numberOfColors)] as Color;
    }

    // blend the color with the trunk color
    nextColor = Color.fromRGBO(
        (nextColor.red * (1 - colorRatio) + trunkFillColor.red * colorRatio)
            .toInt(),
        (nextColor.green * (1 - colorRatio) + trunkFillColor.green * colorRatio)
            .toInt(),
        (nextColor.blue * (1 - colorRatio) + trunkFillColor.blue * colorRatio)
            .toInt(),
        opacity);

    //branch
    if (!justBranched && rnd.nextDouble() < branch) {
      // the ratio is the skewness of the branch.
      // if ratio = 0, both branches go off at the same angle
      // if ratio = 1, one branch goes straight on, the other goes off at the angle
      // the ratio is partially randomized to make things interesting

      // the angle of the branch is the angle from the previous direction.
      // if angle = 0 the tree goes straight up
      // if angle = 1 the tree is basically a ball

      // the animation increases and decreases the ratio
      final double branchRatio = (1 - rnd.nextDouble() / 5) *
          ratio *
          (1 - rnd.nextDouble() * cos(animationVariable * 10000) * 0.50);

      // maxBranch is the max branching angle
      const double maxBranch = pi / 8;

      double directionA;
      double directionB;

      if (rnd.nextBool()) {
        directionA = direction - maxBranch * (angle + 2 * angle * branchRatio);
        directionB =
            direction + maxBranch * (angle + 2 * angle * (1 - branchRatio));
      } else {
        directionA =
            direction - maxBranch * (angle + 2 * angle * (1 - branchRatio));
        directionB = direction + maxBranch * (angle + 2 * angle * branchRatio);
      }

      drawSegment(
        canvas,
        rnd,
        borderX,
        borderY,
        root,
        width,
        segmentLength,
        directionB,
        ratio,
        currentDepth,
        true,
        animationVariable,
        branch,
        angle,
        widthDecay,
        segmentDecay,
        maxDepth,
        trunkFillColor,
        opacity,
        colorDecay,
        colorRatio * colorDecay,
        numberOfColors,
        palette,
        colourOrder,
        randomColors,
      );
      drawSegment(
        canvas,
        rnd,
        borderX,
        borderY,
        root,
        width,
        segmentLength,
        directionA,
        ratio,
        currentDepth,
        true,
        animationVariable,
        branch,
        angle,
        widthDecay,
        segmentDecay,
        maxDepth,
        trunkFillColor,
        opacity,
        colorDecay,
        colorRatio * colorDecay,
        numberOfColors,
        palette,
        colourOrder,
        randomColors,
      );
    } else {
      // draw the trunk
      final List pD = [
        root[0] + segmentLength * cos(direction),
        root[1] - segmentLength * sin(direction)
      ];
      drawTheTrunk(
          canvas, rnd, borderX, borderY, root, pD, nextColor, opacity, width);

      //grow
      drawSegment(
        canvas,
        rnd,
        borderX,
        borderY,
        pD,
        width * widthDecay,
        segmentLength * segmentDecay,
        direction,
        ratio,
        currentDepth + 1,
        false,
        animationVariable,
        branch,
        angle,
        widthDecay,
        segmentDecay,
        maxDepth,
        trunkFillColor,
        opacity,
        colorDecay,
        colorRatio * colorDecay,
        numberOfColors,
        palette,
        colourOrder,
        randomColors,
      );
    }
  }
}

void drawTheTrunk(Canvas canvas, Random rnd, double borderX, double borderY,
    List p1, List p2, Color trunkFillColor, double opacity, double width) {
  canvas.drawLine(
      Offset(p1[0] as double, p1[1] as double),
      Offset(p2[0] as double, p2[1] as double),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = trunkFillColor.withOpacity(opacity)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round);
}
