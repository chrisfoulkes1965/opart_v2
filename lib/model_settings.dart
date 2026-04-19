import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opart_v2/opart_page.dart';

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
    this.tooltip,
    this.icon,
    this.settingCategory,
    this.proFeature,
    this.onChange,
    this.silent,
    this.min,
    this.max,
    this.randomMin,
    this.randomMax,
    this.randomTrue,
    this.zoom,
    this.defaultValue,
    this.options,
  });

  static int _asInt(dynamic v, {required int fallback}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  void randomize(Random rnd) {
    if (!locked) {
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


        case SettingType.int:
          final int min = _asInt(randomMin ?? this.min, fallback: 5);
          final int max = _asInt(randomMax ?? this.max, fallback: 5);

          // half the time use the default
          value = (rnd.nextBool() == true)
              ? rnd.nextInt(max - min) + min
              : defaultValue;


        case SettingType.bool:
          value = (randomTrue != null)
              ? rnd.nextDouble() < randomTrue!
              : rnd.nextBool();


        case SettingType.color:
          value = Color((rnd.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1);


        case SettingType.button:
          value = false;

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
  final dynamic numberOfColoursValue = currentOpArtPageState?.opArt.attributes
      .firstWhere((element) => element.name == 'numberOfColors')
      .value;
  final int numberOfColours = (numberOfColoursValue is num)
      ? numberOfColoursValue.toInt()
      : int.tryParse(numberOfColoursValue?.toString() ?? '') ?? 5;
  final String paletteType = currentOpArtPageState?.opArt.attributes
          .firstWhere((element) => element.name == 'paletteType')
          .value
          .toString() ??
      'random';
  currentOpArtPageState?.opArt.palette.randomize(paletteType, numberOfColours);
}

void checkNumberOfColors() {
  final dynamic numberOfColoursValue = currentOpArtPageState?.opArt.attributes
      .firstWhere((element) => element.name == 'numberOfColors')
      .value;
  final int numberOfColours = (numberOfColoursValue is num)
      ? numberOfColoursValue.toInt()
      : int.tryParse(numberOfColoursValue?.toString() ?? '') ?? 5;
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
