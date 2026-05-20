import 'package:equatable/equatable.dart';

/// Selects a region of the square artwork for print export.
///
/// [centerX] and [centerY] are normalized coordinates (0–1) within the artwork.
/// [size] is the crop window size as a fraction of the largest crop rect that
/// fits on the artwork at the target aspect ratio (1 = as large as possible).
class PrintPlacement extends Equatable {
  const PrintPlacement({
    this.centerX = 0.5,
    this.centerY = 0.5,
    this.size = 1,
  });

  final double centerX;
  final double centerY;
  final double size;

  static const PrintPlacement initial = PrintPlacement();

  PrintPlacement copyWith({
    double? centerX,
    double? centerY,
    double? size,
  }) {
    return PrintPlacement(
      centerX: centerX ?? this.centerX,
      centerY: centerY ?? this.centerY,
      size: size ?? this.size,
    );
  }

  String get cacheKey =>
      'cx${centerX.toStringAsFixed(3)}_cy${centerY.toStringAsFixed(3)}'
      '_s${size.toStringAsFixed(3)}';

  @override
  List<Object?> get props => [centerX, centerY, size];
}
