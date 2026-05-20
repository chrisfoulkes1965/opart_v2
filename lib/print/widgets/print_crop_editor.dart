import 'package:flutter/material.dart';
import 'package:opart_v2/print/models/print_placement.dart';
import 'package:opart_v2/print/models/print_raster_artwork.dart';
import 'package:opart_v2/print/services/print_artwork_raster_service.dart';
import 'package:opart_v2/print/services/print_crop_geometry.dart';

/// Sizes [child] to the print aspect ratio without distorting it.
class PrintCropFrame extends StatelessWidget {
  const PrintCropFrame({
    super.key,
    required this.aspectRatio,
    required this.child,
    this.maxHeight = 480,
  });

  final double aspectRatio;
  final Widget child;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        var width = maxWidth;
        var height = width / aspectRatio;
        if (height > maxHeight) {
          height = maxHeight;
          width = height * aspectRatio;
        }

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        );
      },
    );
  }
}

class PrintCropEditor extends StatefulWidget {
  const PrintCropEditor({
    super.key,
    required this.recipe,
    required this.aspectRatio,
    required this.placement,
    this.rasterService,
    this.interactive = true,
    this.onPlacementChanged,
  });

  final Map<String, dynamic> recipe;
  final double aspectRatio;
  final PrintPlacement placement;
  final PrintArtworkRasterService? rasterService;
  final bool interactive;
  final ValueChanged<PrintPlacement>? onPlacementChanged;

  @override
  State<PrintCropEditor> createState() => PrintCropEditorState();
}

class PrintCropEditorState extends State<PrintCropEditor> {
  static const double _dimOverlayOpacity = 0.5;

  final _repaintTick = ValueNotifier<int>(0);
  PrintArtworkRasterService? _ownedRasterService;

  PrintArtworkRasterService get _rasterService =>
      widget.rasterService ??
      (_ownedRasterService ??= PrintArtworkRasterService());

  PrintPlacement? _activePlacement;
  PrintPlacement? _gestureStartPlacement;
  Offset? _gestureStartFocalNormalized;
  PrintRasterArtwork? _artwork;
  bool _loadingArtwork = true;
  Object? _loadError;

  PrintPlacement get _effectivePlacement =>
      _activePlacement ?? widget.placement;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void dispose() {
    _repaintTick.dispose();
    _ownedRasterService?.clearCache();
    super.dispose();
  }

  @override
  void didUpdateWidget(PrintCropEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipe != widget.recipe) {
      _loadArtwork();
    }
    if (oldWidget.placement != widget.placement) {
      _activePlacement = null;
      _repaintTick.value++;
    }
  }

  PrintPlacement get currentPlacement => _effectivePlacement;

  Future<void> _loadArtwork() async {
    setState(() {
      _loadingArtwork = true;
      _loadError = null;
      _artwork = null;
    });

    try {
      final artwork = await _rasterService.artwork(widget.recipe);
      if (!mounted) {
        return;
      }
      setState(() {
        _artwork = artwork;
        _loadingArtwork = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error;
        _loadingArtwork = false;
      });
    }
  }

  void _onScaleStart(ScaleStartDetails details, Rect artworkRect) {
    _gestureStartPlacement = _effectivePlacement;
    _gestureStartFocalNormalized =
        PrintCropGeometry.viewportToArtworkNormalized(
      viewportPoint: details.localFocalPoint,
      artworkRect: artworkRect,
    );
  }

  void _onScaleUpdate(
    ScaleUpdateDetails details,
    Rect artworkRect,
    double frameAspectRatio,
  ) {
    final start = _gestureStartPlacement;
    final startFocal = _gestureStartFocalNormalized;
    if (start == null || startFocal == null) {
      return;
    }

    final currentFocal = PrintCropGeometry.viewportToArtworkNormalized(
      viewportPoint: details.localFocalPoint,
      artworkRect: artworkRect,
    );

    _activePlacement = PrintCropGeometry.applyScaleGesture(
      start: start,
      startFocalNormalized: startFocal,
      currentFocalNormalized: currentFocal,
      gestureScale: details.scale,
      frameAspectRatio: frameAspectRatio,
      cropAspectRatio: widget.aspectRatio,
    );
    _repaintTick.value++;
  }

  void _onScaleEnd(ScaleEndDetails details) {
    final placement = _activePlacement;
    if (placement != null) {
      widget.onPlacementChanged?.call(placement);
    }
    _gestureStartPlacement = null;
    _gestureStartFocalNormalized = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        if (_loadingArtwork) {
          return _chrome(
            viewportSize: viewportSize,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (_loadError != null) {
          return _chrome(
            viewportSize: viewportSize,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not render design.\n$_loadError',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final artwork = _artwork;
        if (artwork == null) {
          return _chrome(
            viewportSize: viewportSize,
            child: const Center(child: Text('No artwork available.')),
          );
        }

        final content = artwork.contentRect;
        final frameAspectRatio = artwork.contentAspectRatio;
        final artworkRect = PrintCropGeometry.artworkRectForFrame(
          viewportSize: viewportSize,
          frameAspectRatio: frameAspectRatio,
        );

        final painted = ListenableBuilder(
          listenable: _repaintTick,
          builder: (context, child) {
            final cropRect = PrintCropGeometry.cropRectInViewport(
              placement: _effectivePlacement,
              artworkRect: artworkRect,
              frameWidth: content.width,
              frameHeight: content.height,
              cropAspectRatio: widget.aspectRatio,
            );

            return CustomPaint(
              size: viewportSize,
              painter: _RasterCropPainter(
                artwork: artwork,
                artworkRect: artworkRect,
                cropRect: cropRect,
                dimOverlayOpacity: _dimOverlayOpacity,
              ),
            );
          },
        );

        return _chrome(
          viewportSize: viewportSize,
          child: widget.interactive
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: (details) =>
                      _onScaleStart(details, artworkRect),
                  onScaleUpdate: (details) => _onScaleUpdate(
                    details,
                    artworkRect,
                    frameAspectRatio,
                  ),
                  onScaleEnd: _onScaleEnd,
                  child: painted,
                )
              : painted,
        );
      },
    );
  }

  Widget _chrome({
    required Size viewportSize,
    required Widget child,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: viewportSize.width,
          height: viewportSize.height,
          child: child,
        ),
      ),
    );
  }
}

class _RasterCropPainter extends CustomPainter {
  const _RasterCropPainter({
    required this.artwork,
    required this.artworkRect,
    required this.cropRect,
    required this.dimOverlayOpacity,
  });

  final PrintRasterArtwork artwork;
  final Rect artworkRect;
  final Rect cropRect;
  final double dimOverlayOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawImageRect(
      artwork.image,
      artwork.contentRect,
      artworkRect,
      Paint()..filterQuality = FilterQuality.medium,
    );

    final overlayPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect);
    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: dimOverlayOpacity),
    );

    canvas.drawRect(
      cropRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawRect(
      cropRect,
      Paint()
        ..color = Colors.cyan.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RasterCropPainter oldDelegate) {
    return oldDelegate.artwork != artwork ||
        oldDelegate.artworkRect != artworkRect ||
        oldDelegate.cropRect != cropRect ||
        oldDelegate.dimOverlayOpacity != dimOverlayOpacity;
  }
}
