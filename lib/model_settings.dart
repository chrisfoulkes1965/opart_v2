import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opart_v2/opart_page.dart';

import 'main.dart';

// bool proVersion = true;

enum SettingType { double, int, bool, button, color, list }

enum SettingCategory { palette, tool, other }

class SettingsModel {
  SettingType settingType;
  String name;
  String label;
  String? tooltip;
  Icon? icon;
  SettingCategory? settingCategory;
  bool? proFeature;
  dynamic options;
  Function? onChange;
  bool? silent;

  dynamic min;
  dynamic max;
  dynamic randomMin;
  dynamic randomMax;
  double? randomTrue;
  double? zoom;
  dynamic defaultValue;

  bool locked = false;
  dynamic value;

  SettingsModel({
    required this.settingType,
    required this.name,
    required this.label,
    String? tooltip,
    Icon? icon,
    SettingCategory? settingCategory,
    bool? proFeature,
    this.min,
    this.max,
    this.randomMin,
    this.randomMax,
    double? randomTrue,
    double? zoom,
    this.defaultValue,
    this.options,
    Function? onChange,
    bool? silent,
  });

  void randomize(Random rnd) {
    if (!locked && (proVersion || !proVersion && !(proFeature ?? false))) {
      // print('Name: ${name}: ${settingType}');

      switch (settingType) {
        case SettingType.double:
          // print(settingType);
          // print(value);
          final double min =
              (randomMin != null) ? randomMin as double : this.min as double;
          final double max =
              (randomMax != null) ? randomMax as double : this.max as double;

          // half the time use the default
          value = (rnd.nextBool() == true)
              ? rnd.nextDouble() * (max - min) + min
              : defaultValue;

          break;

        case SettingType.int:
          final int min = (randomMin != null)
              ? randomMin.toInt() as int
              : this.min.toInt() ?? 5;
          final int max = (randomMax != null)
              ? randomMax.toInt() as int
              : this.max.toInt() ?? 5;

          // half the time use the default
          value = (rnd.nextBool() == true)
              ? rnd.nextInt(max - min) + min
              : defaultValue;

          break;

        case SettingType.bool:
          value = (randomTrue != null)
              ? rnd.nextDouble() < randomTrue!
              : rnd.nextBool();

          break;

        case SettingType.color:
          value = Color((rnd.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1);

          break;

        case SettingType.button:
          value = false;

          break;
        case SettingType.list:
          value = (rnd.nextBool() == true)
              ? options[rnd.nextInt(options.length as int)]
              : defaultValue;
      }
    }
  }

  void setDefault() {
    value = defaultValue;
    locked = false;
  }
}

void resetAllDefaults() {
  currentOpArtPageState?.opArt.setDefault();
}

void generatePalette() {
  final int numberOfColours = currentOpArtPageState?.opArt.attributes
          .firstWhere((element) => element.name == 'numberOfColors')
          .value
          .toInt() ??
      5;
  final String paletteType = currentOpArtPageState?.opArt.attributes
          .firstWhere((element) => element.name == 'paletteType')
          .value
          .toString() ??
      'random';
  currentOpArtPageState?.opArt.palette.randomize(paletteType, numberOfColours);
}

void checkNumberOfColors() {
  final int numberOfColours = currentOpArtPageState?.opArt.attributes
          .firstWhere((element) => element.name == 'numberOfColors')
          .value
          .toInt() ??
      5;
  final int paletteLength =
      currentOpArtPageState?.opArt.palette.colorList.length ?? 0;
  if (numberOfColours > paletteLength) {
    final String paletteType = currentOpArtPageState?.opArt.attributes
            .firstWhere((element) => element.name == 'paletteType')
            .value
            .toString() ??
        'random';
    currentOpArtPageState?.opArt.palette
        .randomize(paletteType, numberOfColours);
  }
}
