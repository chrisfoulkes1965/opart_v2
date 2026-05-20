import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:opart_v2/app_state.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/opart_overlay_theme.dart';
import 'package:screenshot/screenshot.dart';

class CanvasWidget extends StatefulWidget {
  final bool fullScreen;
  final double animationValue;
  final OpArt opArt;
  const CanvasWidget({
    super.key,
    this.fullScreen = false,
    required this.animationValue,
    required this.opArt,
  });
  @override
  CanvasWidgetState createState() => CanvasWidgetState();
}

class CanvasWidgetState extends State<CanvasWidget>
    with TickerProviderStateMixin {
  bool playing = true;
  late AnimationController animationController;
  late Animation<double> currentAnimation;
  bool showControls = false;

  @override
  void initState() {
    _forward = true;
    timeDilation = 1;

    if (widget.opArt.animation) {
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

  late Hero hero1;
  late Hero hero2;
  bool _forward = true;
  late double dx;
  late double dy;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder<int>(
          valueListenable: rebuildCanvas,
          builder: (context, value, child) {
            return Stack(
              children: [
                Screenshot(
                  controller: screenshotController,
                  child: LayoutBuilder(
                    builder: (_, constraints) => Container(
                      color: Colors.white,
                      width: constraints.widthConstraints().maxWidth,
                      height: constraints.heightConstraints().maxHeight,
                      child: CustomPaint(
                        painter: OpArtPainter(
                          seed,
                          rnd,
                          widget.opArt.animation ? currentAnimation.value : 1,
                          widget.opArt,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
    if (widget.opArt.animation) {
      animationController.dispose();
    }
    super.dispose();
  }
}

class OpArtPainter extends CustomPainter {
  int seed;
  Random rnd;
  double animationVariable;
  OpArt opArt;
  // double fill;

  OpArtPainter(
    this.seed,
    this.rnd,
    this.animationVariable,
    this.opArt,
    // this.fill
  );

  @override
  void paint(Canvas canvas, Size size) {
    opArt.paint(canvas, size, seed, animationVariable);
  }

  @override
  bool shouldRepaint(OpArtPainter oldDelegate) => false;
}
