import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opart_v2/bottom_app_bar.dart';
import 'package:opart_v2/canvas.dart';
import 'package:opart_v2/main.dart';
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
  final bool downloadNow;
  final double animationValue;

  const OpArtPage(
    this.opArtType, {
    this.downloadNow = false,
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
  bool enableButton = true;
  late ScrollController scrollController;
  late File imageFile;
  bool showCustomColorPicker = false;
  late OpArt opArt;
  bool changeSettingsView = true;
  bool highDefDownloadAvailable = false;
  late String highDefPrice;
  late ToolsTab toolsTab;
  late PaletteTab paletteTab;
  late ChoosePaletteTab choosePaletteTab;
  late AnimationController animationController;
  late int seed;
  bool downloadNow = false;

  @override
  void initState() {
    currentOpArtPageState = this;
    downloadNow = widget.downloadNow;
    if (downloadNow) {
      showProgressIndicator = true;
    }
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

  Future<void> _downloadHighResFile() async {
    downloadNow = false;

    try {
      // Wait for the next frame to ensure the widget is fully painted
      await Future.delayed(const Duration(milliseconds: 100));

      // Use WidgetsBinding to wait for the next frame
      await WidgetsBinding.instance.endOfFrame;

      final Uint8List? imageBytes = await screenshotController.capture(
          delay: const Duration(milliseconds: 500), pixelRatio: 10);

      if (imageBytes != null) {
        await Share.shareXFiles(
          [
            XFile.fromData(imageBytes,
                name: 'opart_image.png', mimeType: 'image/png')
          ],
          subject: 'Created using OpArt Lab - download the free app now!',
          text: 'Created using OpArt Lab - download the free app now!',
        );
      }
    } catch (e) {
      print('Error capturing screenshot: $e');
    }

    if (mounted) {
      setState(() {
        showProgressIndicator = false;
        rebuildOpArtPage.value++;
      });
    }
  }

  Future<bool> _shareImage(Uint8List imageBytes) async {
    await Share.shareXFiles(
      [
        XFile.fromData(imageBytes,
            name: 'opart_image.png', mimeType: 'image/png')
      ],
      subject: 'Created using OpArt Lab - download the free app now!',
      text: 'Created using OpArt Lab - download the free app now!',
    );
    return true;
  }

  Future<void> _paymentDialog() async {
    // Wait for the widget to be fully painted
    await Future.delayed(const Duration(milliseconds: 100));
    await WidgetsBinding.instance.endOfFrame;

    final Uint8List? imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 300), pixelRatio: 0.2);

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [
            Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Download Options',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: imageBytes != null
                                    ? Image.memory(imageBytes,
                                        fit: BoxFit.fitWidth)
                                    : Container(),
                              ),
                            ),
                            const Flexible(
                                flex: 2,
                                child: Text(
                                    'Low definition - suitable for sharing.')),
                            Flexible(
                              child: FloatingActionButton.extended(
                                onPressed: () async {
                                  if (imageBytes != null) {
                                    Navigator.pop(context);
                                    await _shareImage(imageBytes);
                                  }
                                },
                                label: const Text('Free!'),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: imageBytes != null
                                    ? Image.memory(imageBytes,
                                        fit: BoxFit.fitWidth)
                                    : Container(),
                              ),
                            ),
                            const Flexible(
                                flex: 2,
                                child: Text(
                                    'High definition - suitable for printing.')),
                            Flexible(
                              child: FloatingActionButton.extended(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  showProgressIndicator = true;
                                  rebuildOpArtPage.value++;
                                  // High definition download logic would go here
                                },
                                label: const Text('Purchase'),
                                backgroundColor: Colors.blue,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (downloadNow) {
      WidgetsBinding.instance.addPostFrameCallback((value) {
        _downloadHighResFile();
      });
    }

    final Size size = MediaQuery.of(context).size;

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
                              opArt.saveToLocalDB(false);
                              showDialog<void>(
                                  context: context,
                                  barrierDismissible: true,
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
                                                                          .length,
                                                                      false)));
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
                            onPressed: () async {
                              await _paymentDialog();
                            }),
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
                            Container(
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: showSettings
                        ? customBottomAppBar(
                            context: context,
                            opArt: opArt,
                            enableButton: enableButton)
                        : const BottomAppBar(),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
