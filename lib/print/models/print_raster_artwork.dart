import 'dart:ui';

/// Flattened design bitmap plus the tight bounds of visible content.
class PrintRasterArtwork {
  const PrintRasterArtwork({
    required this.image,
    required this.contentRect,
  });

  final Image image;
  final Rect contentRect;

  double get contentAspectRatio => contentRect.width / contentRect.height;
}
