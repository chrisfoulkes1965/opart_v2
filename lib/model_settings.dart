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
  List<String>? options;
  VoidCallback? onChange;
  bool? silent;

  Object? min;
  Object? max;
  Object? randomMin;
  Object? randomMax;
  double? randomTrue;
  double? zoom;
  Object? defaultValue;

  bool locked = false;
  Object? value;

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
              (randomMin != null) ? randomMin! as double : this.min! as double;
          final double max =
              (randomMax != null) ? randomMax! as double : this.max! as double;

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
          value = Color(
            (rnd.nextDouble() * 0xFFFFFF).toInt(),
          ).withValues(alpha: 1);

        case SettingType.button:
          value = false;

        case SettingType.list:
          final opts = options;
          if (opts != null && opts.isNotEmpty) {
            value = (rnd.nextBool() == true)
                ? opts[rnd.nextInt(opts.length)]
                : defaultValue;
          }
      }
    }
  }

  void setDefault() {
    value = defaultValue;
    locked = false;
  }

  double get doubleValue {
    final v = value;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    final d = defaultValue;
    if (d is double) return d;
    if (d is num) return d.toDouble();
    return 0.0;
  }

  int get intValue {
    final v = value;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final d = defaultValue;
    if (d is int) return d;
    if (d is num) return d.toInt();
    return 0;
  }

  num get numValue {
    final v = value;
    if (v is num) return v;
    final d = defaultValue;
    if (d is num) return d;
    return 0;
  }

  bool get boolValue => value == true;

  Color get colorValue {
    final v = value;
    if (v is Color) return v;
    final d = defaultValue;
    if (d is Color) return d;
    return Colors.transparent;
  }

  String get stringValue {
    final v = value;
    if (v is String) return v;
    return v?.toString() ?? defaultValue?.toString() ?? '';
  }

  double get minDouble {
    final m = min;
    if (m is num) return m.toDouble();
    return 0.0;
  }

  double get maxDouble {
    final m = max;
    if (m is num) return m.toDouble();
    return 0.0;
  }
}

void resetAllDefaults() {
  currentOpArtPageState?.opArt.setDefault();
}

({Color? background, double opacity}) paletteContrastContext(
  List<SettingsModel> attributes,
) {
  Color? background;
  var opacityValue = 1.0;
  for (final attribute in attributes) {
    if (attribute.name == 'backgroundColor') {
      background = attribute.colorValue;
    } else if (attribute.name == 'opacity') {
      opacityValue = attribute.doubleValue;
    }
  }
  return (background: background, opacity: opacityValue);
}

void generatePalette() {
  final attributes = currentOpArtPageState?.opArt.attributes;
  if (attributes == null) return;
  final int numberOfColours = attributes
      .firstWhere((element) => element.name == 'numberOfColors')
      .intValue;
  final String paletteType = attributes
      .firstWhere((element) => element.name == 'paletteType')
      .stringValue;
  final contrastContext = paletteContrastContext(attributes);
  currentOpArtPageState?.opArt.palette.randomize(
    paletteType,
    numberOfColours,
    background: contrastContext.background,
    opacity: contrastContext.opacity,
  );
}

void checkNumberOfColors() {
  final opArt = currentOpArtPageState?.opArt;
  final attributes = opArt?.attributes;
  if (opArt == null || attributes == null) return;

  final int numberOfColours = attributes
      .firstWhere((element) => element.name == 'numberOfColors')
      .intValue;
  final int paletteLength = opArt.palette.colorList.length;

  if (numberOfColours < paletteLength) {
    opArt.palette.colorList =
        opArt.palette.colorList.sublist(0, numberOfColours);
    return;
  }

  if (numberOfColours > paletteLength) {
    final String paletteType = attributes
        .firstWhere((element) => element.name == 'paletteType')
        .stringValue;
    final contrastContext = paletteContrastContext(attributes);
    opArt.palette.randomize(
      paletteType,
      numberOfColours,
      background: contrastContext.background,
      opacity: contrastContext.opacity,
    );
  }
}
