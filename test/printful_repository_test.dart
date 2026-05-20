import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/print/repositories/printful_repository.dart';

void main() {
  group('PrintfulRepository.formatError', () {
    test('formats Printful rate limit errors', () {
      const error =
          "FunctionException(status: 500, details: {error: You've recently sent too many requests. Please try again after 46 seconds.}, reasonPhrase: Internal Server Error)";

      expect(
        PrintfulRepository.formatError(error),
        'Print preview is temporarily unavailable. '
        'Please wait 46 seconds and try again.',
      );
    });

    test('extracts nested function error details', () {
      const error =
          'FunctionException(status: 400, details: {error: Invalid variant}, reasonPhrase: Bad Request)';

      expect(
        PrintfulRepository.formatError(error),
        'Invalid variant',
      );
    });
  });
}
