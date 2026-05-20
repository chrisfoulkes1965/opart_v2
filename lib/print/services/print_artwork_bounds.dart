import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

/// Finds the tight bounds of non-background pixels in a flattened artwork bitmap.
class PrintArtworkBounds {
  PrintArtworkBounds._();

  static const int _scanStep = 4;
  static const int _colorTolerance = 28;
  static const double _minContentFraction = 0.12;
  static const double _paddingFraction = 0.25;

  static Future<Rect> detectContentRect(
    Image image, {
    Color? backgroundColor,
  }) async {
    final width = image.width;
    final height = image.height;
    if (width <= 0 || height <= 0) {
      return Rect.zero;
    }

    final byteData = await image.toByteData();
    if (byteData == null) {
      return Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    }

    final pixels = byteData.buffer.asUint8List();
    final bg = backgroundColor ?? _sampleBackgroundColor(pixels, width, height);

    var minX = width;
    var minY = height;
    var maxX = 0;
    var maxY = 0;
    var foundContent = false;

    for (var y = 0; y < height; y += _scanStep) {
      for (var x = 0; x < width; x += _scanStep) {
        if (_isBackgroundPixel(pixels, width, x, y, bg)) {
          continue;
        }
        foundContent = true;
        minX = math.min(minX, x);
        minY = math.min(minY, y);
        maxX = math.max(maxX, x);
        maxY = math.max(maxY, y);
      }
    }

    if (!foundContent) {
      return Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    }

    maxX = math.min(width - 1, maxX + _scanStep);
    maxY = math.min(height - 1, maxY + _scanStep);

    var rect = Rect.fromLTWH(
      minX.toDouble(),
      minY.toDouble(),
      (maxX - minX + 1).toDouble(),
      (maxY - minY + 1).toDouble(),
    );

    final minSide = math.min(width, height) * _minContentFraction;
    if (rect.width < minSide || rect.height < minSide) {
      return Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    }

    final padX = rect.width * _paddingFraction;
    final padY = rect.height * _paddingFraction;
    rect = Rect.fromLTRB(
      (rect.left - padX).clamp(0.0, width.toDouble()),
      (rect.top - padY).clamp(0.0, height.toDouble()),
      (rect.right + padX).clamp(0.0, width.toDouble()),
      (rect.bottom + padY).clamp(0.0, height.toDouble()),
    );

    return rect;
  }

  static Color _sampleBackgroundColor(Uint8List pixels, int width, int height) {
    final samples = <Color>[
      _pixelColor(pixels, width, 0, 0),
      _pixelColor(pixels, width, width - 1, 0),
      _pixelColor(pixels, width, 0, height - 1),
      _pixelColor(pixels, width, width - 1, height - 1),
      _pixelColor(pixels, width, width ~/ 2, 0),
      _pixelColor(pixels, width, width ~/ 2, height - 1),
    ];

    var r = 0;
    var g = 0;
    var b = 0;
    for (final color in samples) {
      r += color.red;
      g += color.green;
      b += color.blue;
    }
    final count = samples.length;
    return Color.fromARGB(255, r ~/ count, g ~/ count, b ~/ count);
  }

  static Color _pixelColor(Uint8List pixels, int width, int x, int y) {
    final index = (y * width + x) * 4;
    return Color.fromARGB(
      pixels[index + 3],
      pixels[index],
      pixels[index + 1],
      pixels[index + 2],
    );
  }

  static bool _isBackgroundPixel(
    Uint8List pixels,
    int width,
    int x,
    int y,
    Color background,
  ) {
    final index = (y * width + x) * 4;
    final alpha = pixels[index + 3];
    if (alpha < 16) {
      return true;
    }

    final r = pixels[index];
    final g = pixels[index + 1];
    final b = pixels[index + 2];

    if (_colorDistance(
            r, g, b, background.red, background.green, background.blue) <
        _colorTolerance) {
      return true;
    }

    // Diagonal and similar types often letterbox with pure black.
    if (r < 12 && g < 12 && b < 12) {
      return true;
    }

    return false;
  }

  static int _colorDistance(int r1, int g1, int b1, int r2, int g2, int b2) {
    return (r1 - r2).abs() + (g1 - g2).abs() + (b1 - b2).abs();
  }
}
