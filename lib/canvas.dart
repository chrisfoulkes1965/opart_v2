import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:opart_v2/app_state.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/opart_overlay_theme.dart';
import 'package:screenshot/screenshot.dart';

class CanvasWidget extends StatefulWidget {
  final bool fullScreen;
  final double animationValue;
  final OpArt opArt;
  final bool playAnimation;
  const CanvasWidget({
    super.key,
    this.fullScreen = false,
    required this.animationValue,
    required this.opArt,
    this.playAnimation = true,
  });
  @override
  CanvasWidgetState createState() => CanvasWidgetState();
}

class _CanvasCacheKey {
  const _CanvasCacheKey({
    required this.size,
    required this.seed,
    required this.animationVariable,
    required this.renderGeneration,
  });

  final Size size;
  final int seed;
  final double animationVariable;
  final int renderGeneration;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _CanvasCacheKey &&
            other.size == size &&
            other.seed == seed &&
            other.animationVariable == animationVariable &&
            other.renderGeneration == renderGeneration;
  }

  @override
  int get hashCode =>
      Object.hash(size, seed, animationVariable, renderGeneration);
}

class CanvasWidgetState extends State<CanvasWidget>
    with TickerProviderStateMixin {
  bool playing = true;
  late AnimationController animationController;
  late Animation<double> currentAnimation;
  bool showControls = false;
  late final double _frozenAnimationValue;
  Size? _paintSize;
  ui.Picture? _cachedPicture;
  _CanvasCacheKey? _cacheKey;

  @override
  void initState() {
    _forward = true;
    timeDilation = 1;
    _frozenAnimationValue =
        widget.opArt.animationController?.value ?? widget.animationValue;

    if (!widget.playAnimation) {
      rebuildCanvas.addListener(_invalidatePictureCache);
    }

    if (widget.opArt.animation && widget.playAnimation) {
      animationController = AnimationController(
        duration: const Duration(seconds: 72000),
        vsync: this,
      );
      CurvedAnimation(parent: animationController, curve: Curves.linear);

      final Tween<double> animationTween = Tween(begin: 0, end: 1);

      currentAnimation = animationTween.animate(animationController)
        ..addListener(() {
          rebuildCanvas.value++;
        })
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            animationController.repeat();
          } else if (status == AnimationStatus.dismissed) {
            animationController.forward();
          }
        });

      animationController.forward(from: widget.animationValue);
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = _paintSize ?? MediaQuery.sizeOf(context);
    if (_paintSize == null) {
      _paintSize = size;
      if (!widget.playAnimation) {
        _pictureFor(size);
      }
    }
  }

  late Hero hero1;
  late Hero hero2;
  bool _forward = true;
  late double dx;
  late double dy;

  void _invalidatePictureCache() {
    if (_cacheKey == null && _cachedPicture == null) {
      return;
    }
    _cacheKey = null;
    _cachedPicture?.dispose();
    _cachedPicture = null;
    if (mounted) {
      setState(() {});
    }
  }

  double get _animationVariable {
    if (!widget.playAnimation) {
      return widget.opArt.animationController?.value ?? _frozenAnimationValue;
    }
    if (!widget.opArt.animation) {
      return 1;
    }
    return currentAnimation.value;
  }

  ui.Picture _pictureFor(Size size) {
    final key = _CanvasCacheKey(
      size: size,
      seed: seed,
      animationVariable: _animationVariable,
      renderGeneration: widget.opArt.renderGeneration,
    );
    if (_cacheKey == key && _cachedPicture != null) {
      return _cachedPicture!;
    }

    _cachedPicture?.dispose();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    widget.opArt.syncPaletteForRender();
    widget.opArt.paint(canvas, size, seed, _animationVariable);
    _cachedPicture = recorder.endRecording();
    _cacheKey = key;
    return _cachedPicture!;
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize = _paintSize ?? MediaQuery.sizeOf(context);

    if (!widget.playAnimation) {
      final picture = _pictureFor(canvasSize);
      return RepaintBoundary(
        child: Screenshot(
          controller: screenshotController,
          child: SizedBox(
            width: canvasSize.width,
            height: canvasSize.height,
            child: CustomPaint(
              painter: _CachedPicturePainter(picture),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        ValueListenableBuilder<int>(
          valueListenable: rebuildCanvas,
          builder: (context, value, child) {
            return Screenshot(
              controller: screenshotController,
              child: SizedBox(
                width: canvasSize.width,
                height: canvasSize.height,
                child: CustomPaint(
                  painter: OpArtPainter(
                    seed,
                    rnd,
                    _animationVariable,
                    widget.opArt,
                    canvasSize,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Play/pause overlay; parent should place above the bottom toolbar in the stack.
  Widget buildPlaybackControls() {
    if (!widget.fullScreen || !widget.opArt.animation) {
      return const SizedBox.shrink();
    }

    final bool compact = MediaQuery.sizeOf(context).width < 350;

    return SizedBox(
      height: compact ? 40 : 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showControls)
            RotatedBox(
              quarterTurns: 2,
              child: _controlButton(Icons.fast_forward, () {
                if (timeDilation < 8) {
                  timeDilation = timeDilation * 2;
                }
                _notifyPlaybackChanged();
              }, playing),
            )
          else
            const SizedBox(width: 40),
          if (showControls)
            RotatedBox(
              quarterTurns: 2,
              child: _controlButton(Icons.play_arrow, () {
                setState(() {
                  animationController.reverse();
                  playing = true;
                  _forward = false;
                });
                _notifyPlaybackChanged();
              }, _forward),
            )
          else
            const SizedBox(width: 40),
          if (showControls)
            _controlButton(Icons.pause, () {
              setState(() {
                animationController.stop();
                playing = false;
              });
              _notifyPlaybackChanged();
            }, playing)
          else
            const SizedBox(width: 40),
          if (showControls)
            _controlButton(Icons.play_arrow, () {
              setState(() {
                animationController.forward();
                playing = true;
                _forward = true;
              });
              _notifyPlaybackChanged();
            }, !_forward || !playing)
          else
            const SizedBox(width: 40),
          if (showControls)
            _controlButton(Icons.fast_forward, () {
              if (timeDilation > 0.2) {
                timeDilation = timeDilation / 2;
              }
              _notifyPlaybackChanged();
            }, playing)
          else
            const SizedBox(width: 40),
          _controlButton(showControls ? Icons.close : MdiIcons.playPause, () {
            setState(() {
              showControls = !showControls;
            });
            _notifyPlaybackChanged();
          }, true),
        ],
      ),
    );
  }

  void _notifyPlaybackChanged() {
    rebuildCanvas.value++;
  }

  Widget _controlButton(IconData icon, VoidCallback onPressed, bool active) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: opArtOverlayCircularButtonDecoration(active: active),
          child: Icon(icon,
              size: 20,
              color: active ? opArtOverlayIconSelected : Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (!widget.playAnimation) {
      rebuildCanvas.removeListener(_invalidatePictureCache);
    }
    _cachedPicture?.dispose();
    if (widget.opArt.animation && widget.playAnimation) {
      animationController.dispose();
    }
    super.dispose();
  }
}

class _CachedPicturePainter extends CustomPainter {
  _CachedPicturePainter(this.picture);

  final ui.Picture picture;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPicture(picture);
  }

  @override
  bool shouldRepaint(covariant _CachedPicturePainter oldDelegate) {
    return !identical(oldDelegate.picture, picture);
  }
}

class OpArtPainter extends CustomPainter {
  OpArtPainter(
    this.seed,
    this.rnd,
    this.animationVariable,
    this.opArt,
    this.paintSize,
  );

  int seed;
  Random rnd;
  double animationVariable;
  OpArt opArt;
  Size paintSize;

  @override
  void paint(Canvas canvas, Size size) {
    opArt.paint(canvas, paintSize, seed, animationVariable);
  }

  @override
  bool shouldRepaint(covariant OpArtPainter oldDelegate) {
    return oldDelegate.seed != seed ||
        oldDelegate.animationVariable != animationVariable ||
        oldDelegate.paintSize != paintSize ||
        oldDelegate.opArt.renderGeneration != opArt.renderGeneration;
  }
}
