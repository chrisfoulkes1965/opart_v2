import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opart_v2/bottom_app_bar.dart';
import 'package:opart_v2/canvas.dart';
import 'package:opart_v2/home_page.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/model_settings.dart';
import 'package:opart_v2/mygallery.dart';
import 'package:opart_v2/print/models/opart_recipe.dart';
import 'package:opart_v2/print/pages/print_flow_page.dart';
import 'package:opart_v2/settings_overlay_layout.dart';
import 'package:opart_v2/tabs/color_picker_widget.dart';
import 'package:opart_v2/tabs/general_tab.dart';
import 'package:opart_v2/tabs/tab_widget.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
  bool _shareInProgress = false;
  late OpArt opArt;
  bool changeSettingsView = true;
  late ToolsTab toolsTab;
  late PaletteTab paletteTab;
  late ChoosePaletteTab choosePaletteTab;
  late AnimationController animationController;
  late int seed;
  final GlobalKey<CanvasWidgetState> _canvasKey =
      GlobalKey<CanvasWidgetState>();

  @override
  void initState() {
    super.initState();
    currentOpArtPageState = this;
    slider = 100;

    animationController = AnimationController(
      duration: const Duration(seconds: 72000),
      vsync: this,
    );

    final settings = Map<String, dynamic>.from(widget.opArtSettings);
    if (!settings.containsKey('type')) {
      settings['type'] = widget.opArtType;
    }
    opArt = OpArtRecipe.toOpArt(settings);
    opArt.animationController = animationController;
    seed = OpArtRecipe.seedFrom(settings);
    checkNumberOfColors();
    rebuildCanvas.value++;

    scrollController = ScrollController();
    toolsTab = ToolsTab();
    paletteTab = PaletteTab(context);
    choosePaletteTab = ChoosePaletteTab();
    syncOpArtTabSingletons(toolsTab, paletteTab, choosePaletteTab);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
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

  static const String _shareLogName = 'OpArtShare';
  static const String _shareCaption = 'Created with OpArt Lab';

  void _shareLog(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: _shareLogName,
      error: error,
      stackTrace: stackTrace,
    );
    debugPrint('[$_shareLogName] $message${error != null ? ' | $error' : ''}');
  }

  /// Longest side cap for share exports (WhatsApp iOS hangs on huge PNGs).
  static const double _shareMaxLongestSidePx = 2048;

  double _shareCapturePixelRatio() {
    if (!mounted) {
      return 2;
    }
    final viewSize = MediaQuery.sizeOf(context);
    final maxLogicalSide = math.max(viewSize.width, viewSize.height);
    if (maxLogicalSide <= 0) {
      return 2;
    }
    return (_shareMaxLongestSidePx / maxLogicalSide).clamp(1.0, 4.0);
  }

  /// Anchor rect for the iOS/iPadOS share popover (required on Apple platforms).
  Rect _sharePositionOrigin(BuildContext anchorContext) {
    final box = anchorContext.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final origin = box.localToGlobal(Offset.zero);
      final rect = origin & box.size;
      if (rect.width > 0 && rect.height > 0) {
        return rect;
      }
      return Rect.fromCenter(center: rect.center, width: 1, height: 1);
    }
    final size = MediaQuery.sizeOf(anchorContext);
    final top = MediaQuery.paddingOf(anchorContext).top;
    return Rect.fromCenter(
      center: Offset(size.width - 28, top + kToolbarHeight / 2),
      width: 1,
      height: 1,
    );
  }

  /// Exports a PNG via the system share sheet (free).
  Future<void> _exportHighResPng(BuildContext shareAnchorContext) async {
    if (_shareInProgress) {
      _shareLog('ignored: share already in progress');
      return;
    }
    _shareInProgress = true;

    final stopwatch = Stopwatch()..start();
    final shareOrigin = _sharePositionOrigin(shareAnchorContext);
    final pixelRatio = _shareCapturePixelRatio();

    _shareLog(
      'export started | platform=${Platform.operatingSystem} '
      'mounted=$mounted showSettings=$showSettings pixelRatio=$pixelRatio',
    );
    _shareLog('sharePositionOrigin=$shareOrigin');

    if (mounted) {
      setState(() => showProgressIndicator = true);
      _shareLog(
        'progress indicator shown (+${stopwatch.elapsedMilliseconds}ms)',
      );
    }

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await WidgetsBinding.instance.endOfFrame;
      _shareLog('pre-capture delay done (+${stopwatch.elapsedMilliseconds}ms)');

      _shareLog('screenshot capture starting (pixelRatio=$pixelRatio)');
      final Uint8List? imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 500),
        pixelRatio: pixelRatio,
      );
      _shareLog(
        'screenshot capture finished (+${stopwatch.elapsedMilliseconds}ms) '
        'bytes=${imageBytes?.length ?? 'null'}',
      );

      if (imageBytes == null) {
        _shareLog('aborting: capture returned null');
      } else if (!mounted) {
        _shareLog('aborting: widget unmounted after capture');
      } else {
        final tempDir = await getTemporaryDirectory();
        final filePath = p.join(
          tempDir.path,
          'opart_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        final file = File(filePath);
        await file.writeAsBytes(imageBytes);
        final fileStat = await file.stat();

        _shareLog(
          'temp file written (+${stopwatch.elapsedMilliseconds}ms) '
          'path=$filePath exists=${file.existsSync()} '
          'size=${fileStat.size} bytes',
        );

        if (fileStat.size > 5 * 1024 * 1024) {
          _shareLog(
            'warning: PNG exceeds 5MB — may hang WhatsApp on iOS',
          );
        }

        // Hide loading overlay before the share sheet (overlay can block iOS).
        setState(() => showProgressIndicator = false);
        await WidgetsBinding.instance.endOfFrame;
        _shareLog(
          'opening share sheet, overlay hidden '
          '(+${stopwatch.elapsedMilliseconds}ms)',
        );

        // Caption via [text] only — do not set [subject] with files on iOS or
        // WhatsApp drops the image.
        final ShareResult result = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(filePath, mimeType: 'image/png')],
            text: _shareCaption,
            sharePositionOrigin: shareOrigin,
          ),
        );
        _shareLog(
          'SharePlus.share returned (+${stopwatch.elapsedMilliseconds}ms) '
          'status=${result.status} raw="${result.raw}"',
        );
      }
    } catch (e, st) {
      _shareLog(
        'export failed (+${stopwatch.elapsedMilliseconds}ms)',
        error: e,
        stackTrace: st,
      );
    } finally {
      _shareInProgress = false;
      stopwatch.stop();
      _shareLog('export finished total=${stopwatch.elapsedMilliseconds}ms');
    }

    if (mounted) {
      setState(() {
        showProgressIndicator = false;
        rebuildOpArtPage.value++;
      });
      _shareLog('UI cleanup complete');
    } else {
      _shareLog('skipped UI cleanup: widget no longer mounted');
    }
  }

  /// Opens the print-on-demand shop for the current design.
  void _openPrintShop() {
    final recipe = OpArtRecipe.fromOpArt(
      opArt,
      seed: seed,
      animationValue:
          (widget.opArtSettings['animationControllerValue'] as double?) ?? 1.0,
    );
    unawaited(PrintFlowPage.open(context, recipe: recipe));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: rebuildOpArtPage,
      builder: (context, value, child) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            key: _scaffoldKey,
            extendBodyBehindAppBar: true,
            appBar: showSettings
                ? AppBar(
                    backgroundColor: Colors.cyan.withValues(alpha: 0.8),
                    title: Text(
                      opArt.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'Righteous',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                    elevation: 1,
                    leading: IconButton(
                      icon: const Icon(Icons.home, color: Colors.black),
                      onPressed: () {
                        rebuildMain.value++;
                        showDelete = false;
                        showControls = false;
                        showCustomColorPicker = false;
                        opArt.setDefault();
                        opArt.clearCache();
                        SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.manual,
                          overlays: SystemUiOverlay.values,
                        );
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
                                              'Saved to My Gallery',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            FilledButton(
                                              child: const Text(
                                                'View My Gallery',
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                rebuildMain.value++;
                                                showDelete = false;
                                                showControls = false;
                                                showCustomColorPicker = false;
                                                opArt.setDefault();
                                                opArt.clearCache();
                                                SystemChrome
                                                    .setEnabledSystemUIMode(
                                                  SystemUiMode.manual,
                                                  overlays:
                                                      SystemUiOverlay.values,
                                                );
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyGallery(
                                                      savedOpArt.length,
                                                    ),
                                                  ),
                                                );
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const MyHomePage(
                                                      title: 'OpArt Lab',
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Builder(
                        builder: (shareButtonContext) {
                          return IconButton(
                            icon: const Icon(Icons.share, color: Colors.black),
                            onPressed: () =>
                                _exportHighResPng(shareButtonContext),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.local_print_shop,
                            color: Colors.black),
                        tooltip: 'Print this design',
                        onPressed: _openPrintShop,
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
                            key: _canvasKey,
                            fullScreen: showSettings,
                            animationValue: widget.animationValue,
                            opArt: opArt,
                          ),
                        ),
                      ),
                      if (showProgressIndicator)
                        ColoredBox(
                          color: Colors.white.withValues(alpha: 0.4),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: showSettings
                      ? SafeArea(
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: MediaQuery.of(context).size.width,
                            height: kOpArtHistoryBarHeight,
                            child: ValueListenableBuilder<int>(
                              valueListenable: rebuildCache,
                              builder: (context, value, child) {
                                final cacheLength = opArt.cache.length;
                                return cacheLength == 0
                                    ? Container()
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        controller: scrollController,
                                        itemCount: cacheLength,
                                        itemBuilder: (context, index) {
                                          if (index >= opArt.cache.length) {
                                            return const SizedBox.shrink();
                                          }
                                          final entry = opArt.cache[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 2.0,
                                              horizontal: 4,
                                            ),
                                            child: AspectRatio(
                                              aspectRatio: 1,
                                              child: GestureDetector(
                                                onTap: () {
                                                  opArt.revertToCache(index);
                                                },
                                                child: Image.memory(
                                                  entry['image'] as Uint8List,
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                              },
                            ),
                          ),
                        )
                      : Container(height: 0),
                ),
                if (showSettings) TabWidget(choosePaletteTab),
                if (showSettings) TabWidget(toolsTab),
                if (showSettings) TabWidget(paletteTab),
                if (showCustomColorPicker)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ColorPickerWidget(opArt: opArt),
                  ),
                if (showSettings)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: customBottomAppBar(context: context, opArt: opArt),
                  ),
                if (showSettings && opArt.animation)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ValueListenableBuilder<int>(
                      valueListenable: rebuildCanvas,
                      builder: (context, _, __) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 12,
                            right: 12,
                            bottom: settingsOverlayPlaybackBottom(context),
                          ),
                          child: _canvasKey.currentState
                                  ?.buildPlaybackControls() ??
                              const SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
