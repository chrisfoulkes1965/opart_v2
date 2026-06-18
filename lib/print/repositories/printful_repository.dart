import 'dart:convert';
import 'dart:typed_data';

import 'package:opart_v2/print/models/opart_recipe.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_print_area.dart';
import 'package:opart_v2/print/models/print_spec.dart';
import 'package:opart_v2/print/print_flow_log.dart';
import 'package:opart_v2/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrintfulRepository {
  PrintfulRepository();

  bool get isAvailable => SupabaseService.isConfigured;

  static String formatError(Object error) {
    final message = error.toString();
    final rateLimit = RegExp(
      r'try again after (\d+) seconds',
      caseSensitive: false,
    ).firstMatch(message);
    if (rateLimit != null) {
      final seconds = rateLimit.group(1);
      return 'Print preview is temporarily unavailable. '
          'Please wait $seconds seconds and try again.';
    }
    if (message.contains('FunctionException')) {
      final detail =
          RegExp(r'details: \{error: ([^}]+)\}').firstMatch(message)?.group(1);
      if (detail != null) {
        return detail;
      }
    }
    return message;
  }

  static final RegExp _rateLimitPattern = RegExp(
    r'try again after (\d+) seconds',
    caseSensitive: false,
  );

  Future<List<PrintProduct>> fetchProducts() async {
    final response = await _invokeWithRetry('catalog-products');
    final data = _asMap(response.data);
    _throwIfError('catalog-products', data, response.data);
    final products =
        (data['products'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return products.map(PrintProduct.fromJson).toList();
  }

  Future<PrintPrintArea> fetchPrintArea({
    required int productId,
    required int variantId,
    String? placement,
  }) async {
    final queryParameters = {
      'product_id': '$productId',
      'variant_id': '$variantId',
      if (placement != null && placement.isNotEmpty) 'placement': placement,
    };

    final response = await _invokeWithRetry(
      'catalog-print-area',
      queryParameters: queryParameters,
    );
    final data = _asMap(response.data);
    _throwIfError('catalog-print-area', data, response.data);
    return PrintPrintArea.fromJson(data);
  }

  Future<List<PrintVariant>> fetchVariants(int productId) async {
    final response = await _invokeWithRetry(
      'catalog-variants',
      queryParameters: {'product_id': '$productId'},
    );
    final data = _asMap(response.data);
    _throwIfError('catalog-variants', data, response.data);
    final variants =
        (data['variants'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return variants.map(PrintVariant.fromJson).toList();
  }

  Future<RegisteredDesign> uploadDesign({
    required Uint8List pngBytes,
    required Map<String, dynamic> recipe,
    required PrintSpec spec,
    int? localOpArtId,
  }) async {
    final response = await _invokeWithRetry(
      'designs-register',
      body: {
        'png_base64': base64Encode(pngBytes),
        'design_recipe': OpArtRecipe.toJsonSafe(recipe),
        'local_opart_id': localOpArtId,
        'width_px': spec.widthPx,
        'height_px': spec.heightPx,
      },
    );
    final data = _asMap(response.data);
    _throwIfError('designs-register', data, response.data);

    return RegisteredDesign(
      designId: data['design_id'] as String,
    );
  }

  Future<List<PrintMockup>> generateMockups({
    required int productId,
    required List<int> variantIds,
    required String designId,
    String? placement,
  }) async {
    final response = await _invokeWithRetry(
      'mockups-generate',
      body: {
        'product_id': productId,
        'variant_ids': variantIds,
        'design_id': designId,
        if (placement != null && placement.isNotEmpty) 'placement': placement,
      },
    );
    final data = _asMap(response.data);
    _throwIfError('mockups-generate', data, response.data);
    final mockups =
        (data['mockups'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return mockups.map(PrintMockup.fromJson).toList();
  }

  Future<PrintEstimate> estimateOrder({
    required int variantId,
    required String designId,
    required ShippingAddress address,
    int quantity = 1,
  }) async {
    return estimateBasket(
      items: [
        BasketLineInput(
          variantId: variantId,
          designId: designId,
          quantity: quantity,
        ),
      ],
      address: address,
    );
  }

  Future<PrintEstimate> estimateBasket({
    required List<BasketLineInput> items,
    required ShippingAddress address,
  }) async {
    final response = await _invoke(
      'orders-estimate',
      body: {
        'items': items.map((item) => item.toJson()).toList(),
        'recipient': {
          'country_code': address.countryCode,
          'state_code': address.stateCode,
          'city': address.city,
          'zip': address.zip,
        },
      },
    );
    final data = _asMap(response.data);
    _throwIfError('orders-estimate', data, response.data);
    return PrintEstimate.fromJson(data);
  }

  Future<CheckoutSession> createCheckoutSession({
    required String designId,
    required PrintVariant variant,
    required String productName,
    required ShippingAddress address,
    int quantity = 1,
  }) async {
    return createBasketCheckoutSession(
      items: [
        CheckoutLineInput(
          designId: designId,
          variantId: variant.id,
          productName: productName,
          quantity: quantity,
        ),
      ],
      address: address,
    );
  }

  Future<CheckoutSession> createBasketCheckoutSession({
    required List<CheckoutLineInput> items,
    required ShippingAddress address,
  }) async {
    final response = await _invoke(
      'checkout-create-session',
      body: {
        'items': items.map((item) => item.toJson()).toList(),
        'recipient': address.toJson(),
      },
    );
    final data = _asMap(response.data);
    _throwIfError('checkout-create-session', data, response.data);
    return CheckoutSession.fromJson(data);
  }

  Future<PrintOrderSummary> fetchOrder(String orderId) async {
    final response = await _invoke(
      'orders-get',
      queryParameters: {'order_id': orderId},
    );
    final data = _asMap(response.data);
    _throwIfError('orders-get', data, response.data);
    final order = data['order'] as Map<String, dynamic>;
    return PrintOrderSummary.fromJson(order);
  }

  Future<FunctionResponse> _invokeWithRetry(
    String functionName, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    int maxAttempts = 3,
  }) async {
    Object? lastError;
    StackTrace? lastStackTrace;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await _invoke(
          functionName,
          queryParameters: queryParameters,
          body: body,
        );
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;

        final retryAfterSeconds = _retryAfterSeconds(error);
        if (retryAfterSeconds == null || attempt == maxAttempts - 1) {
          rethrow;
        }

        PrintFlowLog.info(
          '$functionName rate limited; retrying in ${retryAfterSeconds + 1}s '
          '(attempt ${attempt + 2}/$maxAttempts)',
        );
        await Future<void>.delayed(
          Duration(seconds: retryAfterSeconds + 1),
        );
      }
    }

    Error.throwWithStackTrace(lastError!, lastStackTrace!);
  }

  int? _retryAfterSeconds(Object error) {
    final match = _rateLimitPattern.firstMatch(error.toString());
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1)!);
  }

  Future<FunctionResponse> _invoke(
    String functionName, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    PrintFlowLog.info('Invoking $functionName');
    try {
      return await SupabaseService.client.functions.invoke(
        functionName,
        queryParameters: queryParameters,
        body: body,
      );
    } catch (error, stackTrace) {
      PrintFlowLog.error(
        '$functionName invoke failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw PrintfulRepositoryException('Unexpected response from print API');
  }

  void _throwIfError(
    String functionName,
    Map<String, dynamic> data,
    dynamic rawResponse,
  ) {
    if (data['error'] != null) {
      final message = data['error'] as String;
      PrintFlowLog.error(
        '$functionName returned error: $message | raw=$rawResponse',
      );
      throw PrintfulRepositoryException(message);
    }
  }
}

class PrintfulRepositoryException implements Exception {
  PrintfulRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
