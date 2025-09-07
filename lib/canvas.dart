import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:screenshot/screenshot.dart';

import 'main.dart';
import 'model_opart.dart';
import 'opart_page.dart';

class CanvasWidget extends StatefulWidget {
  final bool fullScreen;
  final double animationValue;
  final OpArt opArt;
  const CanvasWidget(
      {this.fullScreen = false,
      required this.animationValue,
      required this.opArt});
  @override
  _CanvasWidgetState createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget>
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

      animationController.forward(from: widget.animationValue ?? 0.0);
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
                          painter: OpArtPainter(seed, rnd,
                              widget.opArt.animation ? currentAnimation.value : 1, widget.opArt),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
        if (widget.fullScreen)
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.opArt.animation)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width < 350 ? 40 : 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (showControls)
                            RotatedBox(
                                quarterTurns: 2,
                                child: _controlButton(
                                  Icons.fast_forward,
                                  () {
                                    if (timeDilation < 8) {
                                      timeDilation = timeDilation * 2;
                                    }
                                  },
                                  playing,
                                ))
                          else
                            Container(),
                          if (showControls)
                            RotatedBox(
                                quarterTurns: 2,
                                child: _controlButton(Icons.play_arrow, () {
                                  setState(() {
                                    animationController.reverse();
                                    playing = true;
                                    _forward = false;
                                  });
                                }, _forward))
                          else
                            Container(),
                          if (showControls)
                            _controlButton(Icons.pause, () {
                              if (animationController != null) {
                                setState(() {
                                  animationController.stop();
                                  playing = false;
                                });
                              }
                            }, playing)
                          else
                            Container(),
                          if (showControls)
                            _controlButton(
                              Icons.play_arrow,
                              () {
                                setState(() {
                                  animationController.forward();
                                  playing = true;
                                  _forward = true;
                                });
                              },
                              !_forward || !playing,
                            )
                          else
                            Container(),
                          if (showControls)
                            _controlButton(
                              Icons.fast_forward,
                              () {
                                if (timeDilation > 0.2) {
                                  timeDilation = timeDilation / 2;
                                }
                              },
                              playing,
                            )
                          else
                            Container(),
                          _controlButton(
                              showControls ? Icons.close : MdiIcons.playPause,
                              () {
                            setState(() {
                              showControls = !showControls;
                            });
                          }, true),
                        ],
                      ),
                    ),
                  )
                else
                  Container(),
                if (widget.fullScreen) Container(height: 70) else Container(),
              ],
            ),
          )
        else
          Container(),
      ],
    );
  }

  Widget _controlButton(IconData icon, Function onPressed, bool active) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 3, color: Colors.white)),
      child: FloatingActionButton(
          backgroundColor: active ? Colors.cyan : Colors.grey,
          heroTag: null,
          onPressed: () {
            onPressed();
          },
          child: Icon(icon)),
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
