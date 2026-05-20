import 'dart:typed_data';

import 'package:opart_v2/print/models/print_placement.dart';
import 'package:opart_v2/print/models/print_spec.dart';
import 'package:opart_v2/print/services/print_artwork_raster_service.dart';

class PrintExportService {
  PrintExportService({PrintArtworkRasterService? rasterService})
      : _rasterService = rasterService ?? PrintArtworkRasterService();

  final PrintArtworkRasterService _rasterService;

  PrintArtworkRasterService get rasterService => _rasterService;

  Future<Uint8List> renderRecipeToPng({
    required Map<String, dynamic> recipe,
    required PrintSpec spec,
    PrintPlacement placement = PrintPlacement.initial,
  }) {
    return _rasterService.renderRecipeToPng(
      recipe: recipe,
      spec: spec,
      placement: placement,
    );
  }
}
