import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opart_v2/bottom_app_bar.dart';
import 'package:opart_v2/canvas.dart';
import 'package:opart_v2/home_page.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/mygallery.dart';
import 'package:opart_v2/tabs/color_picker_widget.dart';
import 'package:opart_v2/tabs/general_tab.dart';
import 'package:opart_v2/tabs/tab_widget.dart';
import 'package:share_plus/share_plus.dart';

// Global reference to current OpArtPage state for tab classes
_OpArtPageState? currentOpArtPageState;

class OpArtPage extends StatefulWidget {
  final OpArtType opArtType;
  final Map<String, dynamic> opArtSettings;
  final double animationValue;

  const OpArtPage(
    this.opArtType, {
    this.opArtSettings = const {},
    required this.animationValue,
  });

  @override
  _OpArtPageState createState() => _OpArtPageState();
}

class _OpArtPageState extends State<OpArtPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showProgressIndicator = false;
  bool showControls = false;
  bool showSettings = true;
  bool showDelete = false;
  int slider = 0;
  late ScrollController scrollController;
  late File imageFile;
  bool showCustomColorPicker = false;
  late OpArt opArt;
  bool changeSettingsView = true;
  late ToolsTab toolsTab;
  late PaletteTab paletteTab;
  late ChoosePaletteTab choosePaletteTab;
  late AnimationController animationController;
  late int seed;

  @override
  void initState() {
    currentOpArtPageState = this;
    slider = 100;

    // Initialize animation controller first
    animationController = AnimationController(
      duration: const Duration(seconds: 72000),
      vsync: this,
    );

    opArt = OpArt(opArtType: widget.opArtType);
    opArt.animationController = animationController;
    seed = (widget.opArtSettings['seed'] as int?) ?? 0;
    for (int i = 0; i < opArt.attributes.length; i++) {
      final attributeKey = opArt.attributes[i].label;
      if (widget.opArtSettings.containsKey(attributeKey)) {
        opArt.attributes[i].value = widget.opArtSettings[attributeKey];
      }
    }
    if (widget.opArtSettings['paletteName'] != null) {
      opArt.palette.paletteName = widget.opArtSettings['paletteName'] as String;
    }
    if (widget.opArtSettings['colors'] != null) {
      opArt.palette.colorList = widget.opArtSettings['colors'] as List<Color>;
    }
    rebuildCanvas.value++;

    scrollController = ScrollController();
    toolsTab = ToolsTab();
    paletteTab = PaletteTab(context);
    choosePaletteTab = ChoosePaletteTab();
    syncOpArtTabSingletons(toolsTab, paletteTab, choosePaletteTab);

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      opArt.saveToCache();

      paletteTab.open = true;
      toolsTab.open = true;
      choosePaletteTab.open = true;
      paletteTab.open = false;
      toolsTab.open = false;
      choosePaletteTab.open = false;
    });
  }

  @override
  void dispose() {
    currentOpArtPageState = null;
    animationController.dispose();
    super.dispose();
  }

  /// Exports a print-quality PNG via the system share sheet (free).
  Future<void> _exportHighResPng() async {
    if (mounted) {
      setState(() => showProgressIndicator = true);
    }

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await WidgetsBinding.instance.endOfFrame;

      final Uint8List? imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 500),
        pixelRatio: 10,
      );

      if (imageBytes != null && mounted) {
        await Share.shareXFiles(
          [
            XFile.fromData(
              imageBytes,
              name: 'opart_image.png',
              mimeType: 'image/png',
            ),
          ],
          subject: 'Created with OpArt Lab',
          text: 'Created with OpArt Lab',
        );
      }
    } catch (e) {
      debugPrint('Error capturing screenshot: $e');
    }

    if (mounted) {
      setState(() {
        showProgressIndicator = false;
        rebuildOpArtPage.value++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: rebuildOpArtPage,
        builder: (context, value, child) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              key: _scaffoldKey,
              extendBodyBehindAppBar: true,
              appBar: showSettings
                  ? AppBar(
                      backgroundColor: Colors.cyan.withOpacity(0.8),
                      title: Text(
                        opArt.name,
                        style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Righteous',
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      centerTitle: true,
                      elevation: 1,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.home,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          rebuildMain.value++;
                          showDelete = false;
                          showControls = false;
                          showCustomColorPicker = false;
                          opArt.setDefault();
                          opArt.clearCache();
                          SystemChrome.setEnabledSystemUIMode(
                              SystemUiMode.manual,
                              overlays: SystemUiOverlay.values);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MyHomePage(title: 'OpArt Lab'),
                            ),
                          );
                        },
                      ),
                      actions: [
                        IconButton(
                            icon: const Icon(Icons.save, color: Colors.black),
                            onPressed: () {
                              opArt.saveToLocalDB();
                              showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                        child: SizedBox(
                                      height: 150,
                                      width: 200,
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                      'Saved to My \nGallery',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(height: 12),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      rebuildMain.value++;
                                                      showDelete = false;
                                                      showControls = false;
                                                      showCustomColorPicker =
                                                          false;
                                                      opArt.setDefault();
                                                      opArt.clearCache();
                                                      SystemChrome
                                                          .setEnabledSystemUIMode(
                                                              SystemUiMode
                                                                  .manual,
                                                              overlays:
                                                                  SystemUiOverlay
                                                                      .values);
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MyGallery(
                                                                      savedOpArt
                                                                          .length)));
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const MyHomePage(
                                                                      title:
                                                                          'OpArt Lab')));
                                                    },
                                                    child: const Text(
                                                        'View My Gallery'),
                                                  )
                                                ]),
                                          ),
                                          const Align(
                                              alignment: Alignment.topRight,
                                              child: Material(
                                                  child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: CloseButton(),
                                              )))
                                        ],
                                      ),
                                    ));
                                  });
                            }),
                        IconButton(
                            icon: const Icon(Icons.share, color: Colors.black),
                            onPressed: _exportHighResPng,
                          ),
                      ],
                    )
                  : null,
              body: Stack(
                children: [
                  GestureDetector(
                      onDoubleTap: () {
                        if (!showSettings) {
                          opArt.randomizeSettings();
                          opArt.randomizePalette();
                          opArt.saveToCache();
                          enableButton = false;
                          rebuildCanvas.value++;
                        }
                      },
                      onTap: () {
                        if (changeSettingsView) {
                          changeSettingsView = false;
                          setState(() {
                            if (showSettings) {
                              slider = 100;
                              if (showCustomColorPicker) {
                                opArt.saveToCache();
                              }
                              showControls = false;
                              showSettings = false;
                              showCustomColorPicker = false;
                            } else {
                              showSettings = true;
                              showCustomColorPicker = false;
                            }
                          });
                          Future.delayed(const Duration(seconds: 1));
                          changeSettingsView = true;
                        }
                      },
                      child: Stack(
                        children: [
                          InteractiveViewer(
                            child: ClipRect(
                                child: CanvasWidget(
                              fullScreen: showSettings,
                              animationValue: widget.animationValue,
                              opArt: opArt,
                            )),
                          ),
                          if (showProgressIndicator)
                            ColoredBox(
                                color: Colors.white.withOpacity(0.4),
                                child: const Center(
                                    child: CircularProgressIndicator()))
                        ],
                      )),
                  Align(
                    alignment: Alignment.topCenter,
                    child: showSettings
                        ? SafeArea(
                            child: Container(
                                color: Colors.white.withOpacity(0.8),
                                width: MediaQuery.of(context).size.width,
                                height: 60,
                                child: ValueListenableBuilder<int>(
                                    valueListenable: rebuildCache,
                                    builder: (context, value, child) {
                                      return opArt.cacheListLength() == 0
                                          ? Container()
                                          : ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              controller: scrollController,
                                              itemCount:
                                                  opArt.cacheListLength(),
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 2.0,
                                                      horizontal: 4),
                                                  child: AspectRatio(
                                                    aspectRatio: 1,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        opArt.revertToCache(
                                                            index);
                                                      },
                                                      child: Image.memory(
                                                          opArt.cache[index]
                                                                  ['image']
                                                              as Uint8List,
                                                          fit: BoxFit.fitWidth),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                    })),
                          )
                        : Container(height: 0),
                  ),
                  if (showSettings) TabWidget(choosePaletteTab),
                  if (showSettings) TabWidget(toolsTab),
                  if (showSettings) TabWidget(paletteTab),
                  if (showCustomColorPicker)
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: ColorPickerWidget(opArt: opArt)),
                  if (showSettings)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: customBottomAppBar(
                        context: context,
                        opArt: opArt,
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }
}
