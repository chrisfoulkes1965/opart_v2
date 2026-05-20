import 'package:flutter/material.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/model_settings.dart';

class OpArtRecipe {
  const OpArtRecipe._();

  static Color? parseColor(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is Color) {
      return raw;
    }
    if (raw is int) {
      return Color(raw);
    }
    if (raw is num) {
      return Color(raw.toInt());
    }

    final text = raw.toString().trim();
    if (text.isEmpty) {
      return null;
    }

    final hexMatch = RegExp(r'0x([0-9a-fA-F]+)').firstMatch(text);
    if (hexMatch != null) {
      return Color(int.parse(hexMatch.group(1)!, radix: 16));
    }

    final componentsMatch = RegExp(
      r'alpha:\s*([\d.]+).*red:\s*([\d.]+).*green:\s*([\d.]+).*blue:\s*([\d.]+)',
    ).firstMatch(text);
    if (componentsMatch != null) {
      final alpha = (double.parse(componentsMatch.group(1)!) * 255).round();
      final red = (double.parse(componentsMatch.group(2)!) * 255).round();
      final green = (double.parse(componentsMatch.group(3)!) * 255).round();
      final blue = (double.parse(componentsMatch.group(4)!) * 255).round();
      return Color.fromARGB(alpha, red, green, blue);
    }

    return null;
  }

  static List<Color>? parseColorList(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is List<Color>) {
      return List<Color>.from(raw);
    }
    if (raw is List) {
      final colors = <Color>[];
      for (final item in raw) {
        final color = parseColor(item);
        if (color != null) {
          colors.add(color);
        }
      }
      return colors.isEmpty ? null : colors;
    }

    final text = raw.toString();
    if (!text.contains('Color(')) {
      return null;
    }

    final colors = <Color>[];
    for (final match in RegExp(r'Color\([^)]*\)').allMatches(text)) {
      final color = parseColor(match.group(0));
      if (color != null) {
        colors.add(color);
      }
    }
    return colors.isEmpty ? null : colors;
  }

  static List<int> colorListToJson(List<Color> colors) {
    return colors.map((color) => color.toARGB32()).toList();
  }

  static bool isColorSettingKey(String key) {
    return key.endsWith(' Color') && key != 'Number of Colors';
  }

  static Map<String, dynamic> fromOpArt(
    OpArt opArt, {
    required int seed,
    required double animationValue,
    int? localOpArtId,
  }) {
    final map = <String, dynamic>{};
    for (final attribute in opArt.attributes) {
      map[attribute.label] = attribute.value;
    }
    map.addAll({
      'seed': seed,
      'colors': opArt.palette.colorList,
      'paletteName': opArt.palette.paletteName,
      'type': opArt.opArtType,
      'animationControllerValue': animationValue,
      if (localOpArtId != null) 'id': localOpArtId,
    });
    return map;
  }

  static OpArt toOpArt(Map<String, dynamic> settings) {
    final type = _parseType(settings['type']);
    final opArt = OpArt(opArtType: type);

    for (final attribute in opArt.attributes) {
      final key = attribute.label;
      if (!settings.containsKey(key)) {
        continue;
      }
      final raw = settings[key];
      if (attribute.settingType == SettingType.color) {
        attribute.value = parseColor(raw) ?? raw;
      } else {
        attribute.value = raw;
      }
    }

    if (settings['paletteName'] != null) {
      opArt.palette.paletteName = settings['paletteName'] as String;
    }

    final savedColors = parseColorList(settings['colors']);
    if (savedColors != null && savedColors.isNotEmpty) {
      opArt.palette.colorList = savedColors;
    }

    opArt.syncPaletteForRender();

    return opArt;
  }

  static int seedFrom(Map<String, dynamic> settings) {
    return (settings['seed'] as int?) ?? 0;
  }

  static double animationValueFrom(Map<String, dynamic> settings) {
    return (settings['animationControllerValue'] as num?)?.toDouble() ?? 1.0;
  }

  static int? localIdFrom(Map<String, dynamic> settings) {
    return settings['id'] as int?;
  }

  static OpArtType _parseType(Object? raw) {
    if (raw is OpArtType) {
      return raw;
    }
    if (raw is String) {
      return OpArtType.values.firstWhere(
        (type) => type.toString() == raw || type.name == raw,
      );
    }
    throw ArgumentError('Unsupported op art type: $raw');
  }

  static Map<String, dynamic> toJsonSafe(Map<String, dynamic> recipe) {
    final json = Map<String, dynamic>.from(recipe);
    if (json['type'] is OpArtType) {
      json['type'] = (json['type'] as OpArtType).toString();
    }
    if (json['colors'] is List<Color>) {
      json['colors'] = (json['colors'] as List<Color>)
          .map((color) => color.toARGB32())
          .toList();
    }
    for (final entry in json.entries.toList()) {
      if (entry.value is Color) {
        json[entry.key] = (entry.value as Color).toARGB32();
      }
    }
    return json;
  }
}
