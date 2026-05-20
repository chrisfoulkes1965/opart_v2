import 'package:equatable/equatable.dart';

class PrintPlacement extends Equatable {
  const PrintPlacement({
    this.scale = 1,
    this.offsetX = 0,
    this.offsetY = 0,
  });

  /// Multiplier on baseline cover fit (1 = fill print area).
  final double scale;

  /// Normalized pan, roughly -1..1 along each axis.
  final double offsetX;
  final double offsetY;

  static const PrintPlacement initial = PrintPlacement();

  PrintPlacement copyWith({
    double? scale,
    double? offsetX,
    double? offsetY,
  }) {
    return PrintPlacement(
      scale: scale ?? this.scale,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
    );
  }

  String get cacheKey =>
      's${scale.toStringAsFixed(3)}_x${offsetX.toStringAsFixed(3)}_y${offsetY.toStringAsFixed(3)}';

  @override
  List<Object?> get props => [scale, offsetX, offsetY];
}
