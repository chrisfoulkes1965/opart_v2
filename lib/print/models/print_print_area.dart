class PrintPrintArea {
  const PrintPrintArea({
    required this.placement,
    required this.widthPx,
    required this.heightPx,
    required this.dpi,
    required this.fillMode,
  });

  final String placement;
  final int widthPx;
  final int heightPx;
  final int dpi;
  final String fillMode;

  factory PrintPrintArea.fromJson(Map<String, dynamic> json) {
    return PrintPrintArea(
      placement: json['placement'] as String? ?? 'default',
      widthPx: json['width_px'] as int? ?? 0,
      heightPx: json['height_px'] as int? ?? 0,
      dpi: json['dpi'] as int? ?? 300,
      fillMode: json['fill_mode'] as String? ?? 'default',
    );
  }
}
