// Dev utility: fetch Printful printfile dimensions for catalog products.
//
// Usage:
//   PRINTFUL_API_TOKEN=your_token dart run tool/printful_catalog_sync.dart
//
// Copy emitted PrintSpec constants into lib/print/models/print_spec_templates.dart.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:opart_v2/print/models/print_product_definition.dart';

const _printfulBase = 'https://api.printful.com';

Future<void> main() async {
  final token = Platform.environment['PRINTFUL_API_TOKEN'];
  if (token == null || token.isEmpty) {
    stderr.writeln('Set PRINTFUL_API_TOKEN to run this script.');
    exitCode = 1;
    return;
  }

  for (final definition in PrintProductRegistry.all) {
    final productId = definition.productId;
    stdout.writeln('\n// Product $productId (${definition.behavior.name})');

    try {
      final productResponse = await _get(
        token,
        '/products/$productId',
      );
      final productTitle = productResponse['result']?['product']?['title'] ??
          productResponse['result']?['title'] ??
          'Unknown';
      stdout.writeln('// $productTitle');

      final printfiles = await _get(
        token,
        '/mockup-generator/printfiles/$productId',
      );
      final result = printfiles['result'] as Map<String, dynamic>?;
      if (result == null) {
        stdout.writeln('// No printfiles result');
        continue;
      }

      final placements =
          result['available_placements'] as Map<String, dynamic>? ?? {};
      stdout.writeln('// Placements: ${placements.keys.join(', ')}');

      final files = result['printfiles'] as List<dynamic>? ?? [];
      for (final file in files) {
        final map = file as Map<String, dynamic>;
        final width = map['width'] as int? ?? 0;
        final height = map['height'] as int? ?? 0;
        final dpi = map['dpi'] as int? ?? 300;
        final id = map['printfile_id'];
        stdout.writeln(
          '// printfile_id=$id ${width}x$height @ ${dpi}dpi '
          '(${width / dpi}" x ${height / dpi}")',
        );
      }

      stdout.writeln(_suggestDartSpec(productId, files));
    } catch (error) {
      stderr.writeln('// Product $productId failed: $error');
    }
  }
}

Future<Map<String, dynamic>> _get(String token, String path) async {
  final response = await http.get(
    Uri.parse('$_printfulBase$path'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode < 200 || response.statusCode >= 300) {
    final message = body['error']?['message'] ?? response.body;
    throw HttpException('${response.statusCode}: $message');
  }

  return body;
}

String _suggestDartSpec(int productId, List<dynamic> files) {
  if (files.isEmpty) {
    return '// (no printfiles)';
  }

  final file = files.first as Map<String, dynamic>;
  final width = file['width'] as int? ?? 0;
  final height = file['height'] as int? ?? 0;
  final dpi = file['dpi'] as int? ?? 300;
  final widthInches = (width / dpi).toStringAsFixed(2);
  final heightInches = (height / dpi).toStringAsFixed(2);

  return '''
const PrintSpec(
  id: 'default',
  label: 'Print area',
  widthPx: $width,
  heightPx: $height,
  dpi: $dpi,
  widthInches: $widthInches,
  heightInches: $heightInches,
  printfulProductId: $productId,
),''';
}
