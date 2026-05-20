import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:opart_v2/print/models/print_placement.dart';

class PrintCropEditor extends StatefulWidget {
  const PrintCropEditor({
    super.key,
    required this.squareArtworkBytes,
    required this.aspectRatio,
    required this.placement,
    required this.onPlacementChanged,
  });

  final Uint8List squareArtworkBytes;
  final double aspectRatio;
  final PrintPlacement placement;
  final ValueChanged<PrintPlacement> onPlacementChanged;

  @override
  State<PrintCropEditor> createState() => _PrintCropEditorState();
}

class _PrintCropEditorState extends State<PrintCropEditor> {
  PrintPlacement? _gestureStartPlacement;
  Offset? _gestureStartFocalPoint;

  double _baselineSide(double frameWidth, double frameHeight) {
    return math.max(frameWidth, frameHeight);
  }

  /// Mirrors [PrintExportService._paintOpArtInRect] so crop matches preview.
  _CropLayout _layoutFor(
    PrintPlacement placement,
    double frameWidth,
    double frameHeight,
  ) {
    final baseline = _baselineSide(frameWidth, frameHeight);
    final scale = placement.scale.clamp(0.5, 4.0);
    final paintedSide = baseline * scale;
    final maxPanX = math.max(0.0, (paintedSide - frameWidth) / 2);
    final maxPanY = math.max(0.0, (paintedSide - frameHeight) / 2);
    final panX = placement.offsetX.clamp(-1.0, 1.0) * maxPanX;
    final panY = placement.offsetY.clamp(-1.0, 1.0) * maxPanY;
    final left = (frameWidth - paintedSide) / 2 + panX;
    final top = (frameHeight - paintedSide) / 2 + panY;

    return _CropLayout(
      paintedSide: paintedSide,
      maxPanX: maxPanX,
      maxPanY: maxPanY,
      left: left,
      top: top,
    );
  }

  PrintPlacement _placementFromPosition({
    required double left,
    required double top,
    required double scale,
    required double frameWidth,
    required double frameHeight,
  }) {
    final baseline = _baselineSide(frameWidth, frameHeight);
    final clampedScale = scale.clamp(0.5, 4.0);
    final paintedSide = baseline * clampedScale;
    final maxPanX = math.max(0.0, (paintedSide - frameWidth) / 2);
    final maxPanY = math.max(0.0, (paintedSide - frameHeight) / 2);

    final offsetX = maxPanX > 0
        ? ((left - (frameWidth - paintedSide) / 2) / maxPanX).clamp(-1.0, 1.0)
        : 0.0;
    final offsetY = maxPanY > 0
        ? ((top - (frameHeight - paintedSide) / 2) / maxPanY).clamp(-1.0, 1.0)
        : 0.0;

    return PrintPlacement(
      scale: clampedScale,
      offsetX: offsetX,
      offsetY: offsetY,
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gestureStartPlacement = widget.placement;
    _gestureStartFocalPoint = details.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size frameSize) {
    final startPlacement = _gestureStartPlacement;
    final startFocalPoint = _gestureStartFocalPoint;
    if (startPlacement == null || startFocalPoint == null) {
      return;
    }

    final newScale = (startPlacement.scale * details.scale).clamp(0.5, 4.0);
    final startLayout = _layoutFor(
      startPlacement,
      frameSize.width,
      frameSize.height,
    );
    final scaleRatio = newScale / startPlacement.scale;

    var left = startFocalPoint.dx -
        (startFocalPoint.dx - startLayout.left) * scaleRatio;
    var top = startFocalPoint.dy -
        (startFocalPoint.dy - startLayout.top) * scaleRatio;

    left += details.localFocalPoint.dx - startFocalPoint.dx;
    top += details.localFocalPoint.dy - startFocalPoint.dy;

    widget.onPlacementChanged(
      _placementFromPosition(
        left: left,
        top: top,
        scale: newScale,
        frameWidth: frameSize.width,
        frameHeight: frameSize.height,
      ),
    );
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _gestureStartPlacement = null;
    _gestureStartFocalPoint = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pinch and drag to position your design',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final frameSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final layout = _layoutFor(
                widget.placement,
                frameSize.width,
                frameSize.height,
              );

              return DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: GestureDetector(
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: (details) =>
                        _onScaleUpdate(details, frameSize),
                    onScaleEnd: _onScaleEnd,
                    child: SizedBox(
                      width: frameSize.width,
                      height: frameSize.height,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned(
                            left: layout.left,
                            top: layout.top,
                            width: layout.paintedSide,
                            height: layout.paintedSide,
                            child: Image.memory(
                              widget.squareArtworkBytes,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CropLayout {
  const _CropLayout({
    required this.paintedSide,
    required this.maxPanX,
    required this.maxPanY,
    required this.left,
    required this.top,
  });

  final double paintedSide;
  final double maxPanX;
  final double maxPanY;
  final double left;
  final double top;
}
