// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:opart_v2/app_state.dart';
import 'package:opart_v2/database_helper.dart';
import 'package:opart_v2/model_palette.dart';
import 'package:opart_v2/model_settings.dart';
import 'package:opart_v2/opart/opart_diagonal.dart';
import 'package:opart_v2/opart/opart_eye.dart';
import 'package:opart_v2/opart/opart_fibonacci.dart';
import 'package:opart_v2/opart/opart_flow.dart';
import 'package:opart_v2/opart/opart_hexagons.dart';
import 'package:opart_v2/opart/opart_life.dart';
import 'package:opart_v2/opart/opart_maze.dart';
import 'package:opart_v2/opart/opart_neighbour.dart';
import 'package:opart_v2/opart/opart_plasma.dart';
import 'package:opart_v2/opart/opart_quads.dart';
import 'package:opart_v2/opart/opart_rhombus.dart';
import 'package:opart_v2/opart/opart_riley.dart';
import 'package:opart_v2/opart/opart_shapes.dart';
import 'package:opart_v2/opart/opart_squares.dart';
import 'package:opart_v2/opart/opart_string.dart';
import 'package:opart_v2/opart/opart_tree.dart';
import 'package:opart_v2/opart/opart_triangles.dart';
import 'package:opart_v2/opart/opart_wallpaper.dart';
import 'package:opart_v2/opart/opart_wave.dart';
import 'package:opart_v2/palette_contrast.dart';
import 'package:opart_v2/print/models/opart_recipe.dart';
import 'package:screenshot/screenshot.dart';

List<Map<String, dynamic>> savedOpArt = [];
ScreenshotController screenshotController = ScreenshotController();

final rebuildCache = ValueNotifier(0);
final rebuildMain = ValueNotifier(0);
final rebuildCanvas = ValueNotifier(0);
final rebuildOpArtPage = ValueNotifier(0);
final rebuildTab = ValueNotifier(0);
final rebuildGallery = ValueNotifier(0);
final rebuildDialog = ValueNotifier(0);
final rebuildColorPicker = ValueNotifier(0);

bool enableButton = true;

ScrollController scrollController = ScrollController();

enum OpArtType {
  Diagonal,
  Eye,
  Flow,
  Fibonacci,
  Hexagons,
  Life,
  Maze,
  Neighbour,
  Plasma,
  Quads,
  Rhombus,
  Riley,
  Shapes,
  Squares,
  String,
  Tree,
  Triangles,
  Wallpaper,
  Wave,
}

class OpArtTypes {
  String name;
  OpArtType opArtType;
  String image;
  OpArtTypes(this.name, this.opArtType, this.image);
}

class OpArt {
  OpArtType opArtType;
  List<SettingsModel> attributes = [];
  List<Map<String, dynamic>> cache = [];
  // Random rnd = Random();
  late OpArtPalette palette;
  late String name;
  bool animation = true;
  AnimationController? animationController;
  int renderGeneration = 0;
  Timer? _cacheSaveDebounce;
  int _cacheCaptureGeneration = 0;

  void markRenderDirty() {
    renderGeneration++;
  }

  // Initialise
  OpArt({required this.opArtType}) {
    // Initialize required fields first to prevent LateInitializationError
    palette = OpArtPalette();
    name = 'Default';

    switch (opArtType) {
      case OpArtType.Diagonal:
        attributes = initializeDiagonalAttributes();
        name = 'Diagonal';
        animation = false;
      case OpArtType.Eye:
        attributes = initializeEyeAttributes();
        name = 'Eye';
        animation = false;
      case OpArtType.Fibonacci:
        attributes = initializeFibonacciAttributes();
        name = 'Spirals';
      case OpArtType.Hexagons:
        attributes = initializeHexagonsAttributes();
        name = 'Hexagons';
        animation = false;
      case OpArtType.Life:
        attributes = initializeLifeAttributes();
        name = 'Life';
        animation = true;
      case OpArtType.Maze:
        attributes = initializeMazeAttributes();
        name = 'Maze';
        animation = false;
      case OpArtType.Plasma:
        attributes = initializePlasmaAttributes();
        name = 'Plasma';
        animation = true;
      case OpArtType.Quads:
        attributes = initializeQuadsAttributes();
        name = 'Quads';
        animation = false;
      case OpArtType.Rhombus:
        attributes = initializeRhombusAttributes();
        name = 'Rhombus';
      case OpArtType.Riley:
        attributes = initializeRileyAttributes();
        name = 'Riley';
        animation = false;
      case OpArtType.Flow:
        attributes = initializeFlowAttributes();
        name = 'Flow';
        animation = false;
      case OpArtType.Shapes:
        attributes = initializeShapesAttributes();
        name = 'Shapes';
        animation = false;
      case OpArtType.String:
        attributes = initializeStringAttributes();
        name = 'String';
        animation = false;
      case OpArtType.Tree:
        attributes = initializeTreeAttributes();
        name = 'Tree';
        animation = true;
      case OpArtType.Triangles:
        attributes = initializeTrianglesAttributes();
        name = 'Triangles';
        animation = false;
      case OpArtType.Wallpaper:
        attributes = initializeWallpaperAttributes();
        name = 'Wallpaper';
        animation = false;
      case OpArtType.Wave:
        attributes = initializeWaveAttributes();
        name = 'Wave';
      case OpArtType.Neighbour:
        attributes = initializeNeighbourAttributes();
        name = 'Neighbour';
        animation = false;
      case OpArtType.Squares:
        attributes = initializeSquaresAttributes();
        name = 'Squares';
        animation = false;
    }

    setDefault();
  }

  Future<int> saveToLocalDB() async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 200),
      );

      if (imageBytes == null) return 0;

      final String base64Image = base64Encode(imageBytes);
      final Map<String, dynamic> map = {};
      for (int i = 0; i < attributes.length; i++) {
        map.addAll({attributes[i].label: attributes[i].value});
      }
      map.addAll({
        'seed': seed,
        'colors': palette.colorList,
        'image': base64Image,
        'paletteName': palette.paletteName,
        'type': opArtType,
        'paid': false,
        'animationControllerValue': animation && animationController != null
            ? animationController!.value
            : 1.0,
      });

      final Map<String, dynamic> sqlMap = {};

      for (int i = 0; i < attributes.length; i++) {
        if (attributes[i].settingType == SettingType.color) {
          sqlMap.addAll({
            attributes[i].label: (attributes[i].value as Color).toARGB32(),
          });
        } else {
          sqlMap.addAll({attributes[i].label: attributes[i].value});
        }
      }
      sqlMap.addAll({
        'seed': seed,
        'colors': OpArtRecipe.colorListToJson(palette.colorList),
        'image': base64Image,
        'paletteName': palette.paletteName,
        'type': opArtType.toString(),
        'paid': false,
        'animationControllerValue': animation && animationController != null
            ? animationController!.value
            : 1.0,
      });

      final DatabaseHelper helper = DatabaseHelper.instance;
      await helper.insert(sqlMap).then((id) {
        map.addAll({'id': id});
        savedOpArt.add(map);
        rebuildMain.value++;
        rebuildGallery.value++;
      });
      return savedOpArt.length;
    } catch (e) {
      debugPrint('Error saving to local DB: $e');
      return 0;
    }
  }

  void saveToCache({bool immediate = false}) {
    if (immediate) {
      _cacheSaveDebounce?.cancel();
      _captureCacheSnapshot();
      return;
    }

    _cacheSaveDebounce?.cancel();
    _cacheSaveDebounce = Timer(const Duration(milliseconds: 350), () {
      _captureCacheSnapshot();
    });
  }

  void _captureCacheSnapshot() {
    final int generation = ++_cacheCaptureGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await WidgetsBinding.instance.endOfFrame;
        if (generation != _cacheCaptureGeneration) {
          return;
        }

        final Uint8List? imageBytes = await screenshotController.capture(
          pixelRatio: 0.2,
        );

        if (generation != _cacheCaptureGeneration || imageBytes == null) {
          return;
        }

        final Map<String, dynamic> map = {};
        for (int i = 0; i < attributes.length; i++) {
          map.addAll({attributes[i].label: attributes[i].value});
        }
        map.addAll({
          'seed': seed,
          'image': imageBytes,
          'paletteName': palette.paletteName,
          'colors': palette.colorList,
          'numberOfColors': numberOfColors.value,
          'animationControllerValue': animation && animationController != null
              ? animationController!.value
              : 1.0,
        });

        cache.add(map);

        rebuildCache.value++;
        if (scrollController.hasClients) {
          await scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
          );
        }
      } catch (e) {
        debugPrint('Error saving to cache: $e');
      } finally {
        if (generation == _cacheCaptureGeneration) {
          enableButton = true;
        }
      }
    });
  }

  void revertToCache(int index) {
    markRenderDirty();
    seed = cache[index]['seed'] as int;
    if (animation && animationController != null) {
      animationController!.forward(
        from: cache[index]['animationControllerValue'] as double,
      );
    }
    for (int i = 0; i < attributes.length; i++) {
      attributes[i].value = cache[index][attributes[i].label];
    }
    numberOfColors.value = cache[index]['numberOfColors'];
    palette.paletteName = cache[index]['paletteName'] as String;
    palette.colorList = cache[index]['colors'] as List<Color>;

    rebuildCanvas.value++;
    rebuildTab.value++;
  }

  void clearCache() {
    cache.clear();
    rebuildCache.value++;
  }

  void syncPaletteForRender() {
    final paletteListAttr = _attributeByName('paletteList');

    if (palette.colorList.isNotEmpty) {
      if (paletteListAttr != null) {
        final selectedName = paletteListAttr.stringValue;
        if (selectedName.isNotEmpty) {
          palette.paletteName = selectedName;
        }
      }
    } else if (paletteListAttr != null && palette.paletteName.isNotEmpty) {
      try {
        selectPalette(palette.paletteName);
        paletteListAttr.value = palette.paletteName;
      } catch (_) {
        // Unknown palette name — fall back to in-memory defaults.
      }
    }

    final numberOfColorsAttr = _attributeByName('numberOfColors');
    if (numberOfColorsAttr == null || palette.colorList.isEmpty) {
      return;
    }

    final int numberOfColours = numberOfColorsAttr.intValue;
    final int paletteLength = palette.colorList.length;

    if (numberOfColours > paletteLength) {
      numberOfColorsAttr.value = paletteLength;
    } else if (numberOfColours < paletteLength) {
      palette.colorList = palette.colorList.sublist(0, numberOfColours);
    }
  }

  void paint(Canvas canvas, Size size, int seed, double animationVariable) {
    syncPaletteForRender();
    switch (opArtType) {
      case OpArtType.Diagonal:
        paintDiagonal(canvas, size, seed, animationVariable, this);
      case OpArtType.Eye:
        paintEye(canvas, size, seed, animationVariable, this);
      case OpArtType.Fibonacci:
        paintFibonacci(canvas, size, seed, animationVariable, this);
      case OpArtType.Flow:
        paintFlow(canvas, size, seed, animationVariable, this);
      case OpArtType.Hexagons:
        paintHexagons(canvas, size, seed, animationVariable, this);
      case OpArtType.Life:
        paintLife(canvas, size, seed, animationVariable, this);
      case OpArtType.Maze:
        paintMaze(canvas, size, seed, animationVariable, this);
      case OpArtType.Neighbour:
        paintNeighbour(canvas, size, seed, animationVariable, this);
      case OpArtType.Plasma:
        paintPlasma(canvas, size, seed, animationVariable, this);
      case OpArtType.Quads:
        paintQuads(canvas, size, seed, animationVariable, this);
      case OpArtType.Rhombus:
        paintRhombus(canvas, size, seed, animationVariable, this);
      case OpArtType.Riley:
        paintRiley(canvas, size, seed, animationVariable, this);
      case OpArtType.Shapes:
        paintShapes(canvas, size, seed, animationVariable, this);
      case OpArtType.Squares:
        paintSquares(canvas, size, seed, animationVariable, this);
      case OpArtType.String:
        paintString(canvas, size, seed, animationVariable, this);
      case OpArtType.Tree:
        paintTree(canvas, size, seed, animationVariable, this);
      case OpArtType.Triangles:
        paintTriangles(canvas, size, seed, animationVariable, this);
      case OpArtType.Wallpaper:
        paintWallpaper(canvas, size, seed, animationVariable, this);
      case OpArtType.Wave:
        paintWave(canvas, size, seed, animationVariable, this);
    }
  }

  // randomise the non-palette settings
  void randomizeSettings() {
    markRenderDirty();
    seed = DateTime.now().millisecond;
    final Random rnd = Random(seed);

    for (int i = 0; i < attributes.length; i++) {
      if (attributes[i].settingCategory == SettingCategory.tool) {
        attributes[i].randomize(rnd);
      }
    }
  }

  // select a palette from the list
  void selectPalette(String paletteName) {
    final List<Object?> newPalette = defaultPalettes.firstWhere(
      (List<Object?> palette) => palette[0] == paletteName,
    );
    this.palette.paletteName = paletteName;
    palette.colorList = [];
    final List<String> colorStrings = List<String>.from(
      (newPalette[3]! as List<Object?>).map((e) => e.toString()),
    );
    for (var z = 0; z < colorStrings.length; z++) {
      palette.colorList.add(Color(int.parse(colorStrings[z])));
    }
    attributes.firstWhere((element) => element.name == 'numberOfColors').value =
        min((newPalette[1]! as num).toInt(), palette.colorList.length);
    backgroundColor.value = Color(int.parse(newPalette[2]! as String));
  }

  SettingsModel? _attributeByName(String name) {
    for (final attribute in attributes) {
      if (attribute.name == name) {
        return attribute;
      }
    }
    return null;
  }

  // randomise the palette (does not change [seed] — shape stays stable)
  void randomizePalette() {
    markRenderDirty();
    final Random rnd = Random();

    for (int i = 0; i < attributes.length; i++) {
      if (attributes[i].settingCategory == SettingCategory.palette &&
          attributes[i].name == 'backgroundColor') {
        attributes[i].randomize(rnd);
      }
    }

    for (int i = 0; i < attributes.length; i++) {
      if (attributes[i].settingCategory == SettingCategory.palette &&
          attributes[i].name != 'backgroundColor') {
        attributes[i].randomize(rnd);
      }
    }

    final Color? background = _attributeByName('backgroundColor')?.colorValue;
    final double paletteOpacity =
        _attributeByName('opacity')?.doubleValue ?? 1.0;

    palette.randomize(
      attributes.firstWhere((element) => element.name == 'paletteType').value!
          as String,
      (attributes
              .firstWhere((element) => element.name == 'numberOfColors')
              .value! as num)
          .toInt(),
      background: background,
      opacity: paletteOpacity,
    );

    final SettingsModel? lineWidthSetting = _attributeByName('lineWidth');
    if (background != null &&
        lineWidthSetting != null &&
        lineWidthSetting.doubleValue > 0) {
      final SettingsModel lineColorSetting = attributes.firstWhere(
        (element) => element.name == 'lineColor',
      );
      lineColorSetting.value = ensureContrastAgainstBackground(
        color: lineColorSetting.colorValue,
        background: background,
      );
    }

    attributes.firstWhere((element) => element.name == 'paletteList').value =
        'Default';
  }

  // reset to defaults
  void setDefault() {
    for (int i = 0; i < attributes.length; i++) {
      attributes[i].setDefault();
    }

    final List<Object?> newPalette = defaultPalettes.firstWhere(
      (List<Object?> palette) => palette[0] == 'Default',
    );

    backgroundColor.value = Color(int.parse(newPalette[2]! as String));
    palette.colorList = [];
    final List<String> colorStrings = List<String>.from(
      (newPalette[3]! as List<Object?>).map((e) => e.toString()),
    );
    for (var z = 0; z < colorStrings.length; z++) {
      palette.colorList.add(Color(int.parse(colorStrings[z])));
    }
  }

  // Map<String, dynamic> toMap() {
  //   Map<String, dynamic> currentMap = {
  //     'opArtType': this.opArtType,
  //     'palette': this.palette,
  //   };
  //   return currentMap;
  // }
  //
  // void fromMap(Map<String, dynamic> map) {
  //   this.opArtType = map['opArtType'];
  //   this.palette = map['palette'];
  // }
}
