import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/print_catalog.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_placement.dart';
import 'package:opart_v2/print/models/print_spec.dart';
import 'package:opart_v2/print/print_flow_log.dart';
import 'package:opart_v2/print/repositories/printful_repository.dart';
import 'package:opart_v2/print/services/print_export_service.dart';

class PrintFlowCubit extends Cubit<PrintFlowState> {
  PrintFlowCubit({
    required Map<String, dynamic> recipe,
    PrintfulRepository? repository,
    PrintExportService? exportService,
  })  : _repository = repository ?? PrintfulRepository(),
        _exportService = exportService ?? const PrintExportService(),
        super(PrintFlowState(recipe: recipe));

  final PrintfulRepository _repository;
  final PrintExportService _exportService;

  final Map<String, RegisteredDesign> _designsByArtworkKey = {};
  final Map<String, Future<RegisteredDesign>> _designFuturesByArtworkKey = {};

  int? _activeProductId;

  Future<void> initialize() async {
    if (!state.hasValidRecipe) {
      _emitError(
        context: 'initialize',
        message: 'Create and save a design before printing.',
        status: PrintFlowStatus.failure,
      );
      return;
    }

    if (!_repository.isAvailable) {
      _emitError(
        context: 'initialize',
        message:
            'Print shop is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.',
        status: PrintFlowStatus.failure,
      );
      return;
    }

    emit(
      state.copyWith(
        status: PrintFlowStatus.loading,
        progressMessage: 'Loading products…',
        clearError: true,
      ),
    );

    try {
      final products = await _repository.fetchProducts();
      final previews = await _buildProductPreviews(products);

      emit(
        state.copyWith(
          status: PrintFlowStatus.ready,
          products: products,
          productPreviewByProductId: previews,
          progressMessage: null,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _emitError(
        context: 'initialize',
        message: error.toString(),
        error: error,
        stackTrace: stackTrace,
        status: PrintFlowStatus.failure,
      );
    }
  }

  Future<Map<int, Uint8List>> _buildProductPreviews(
    List<PrintProduct> products,
  ) async {
    final previews = <int, Uint8List>{};
    final fit = PrintFitMode.cover;

    for (final product in products) {
      final spec = PrintCatalog.canonicalPreviewSpec(product.id)
          .scaledToMaxDimension(PrintCatalog.previewMaxDimensionPx);

      previews[product.id] = await _exportService.renderRecipeToPng(
        recipe: state.recipe,
        spec: spec,
        fit: fit,
        placement: PrintPlacement.initial,
      );
    }

    return previews;
  }

  Future<void> selectProduct(PrintProduct product) async {
    _activeProductId = product.id;
    _designsByArtworkKey.clear();
    _designFuturesByArtworkKey.clear();

    emit(
      state.copyWith(
        selectedProduct: product,
        step: PrintFlowStep.variant,
        status: PrintFlowStatus.loading,
        progressMessage: 'Loading sizes…',
        variants: const [],
        selectedVariant: null,
        selectedSpec: null,
        placement: PrintPlacement.initial,
        registeredDesign: null,
        clearSquareArtworkBytes: true,
        clearPreviewMockupUrl: true,
        clearError: true,
      ),
    );

    try {
      final variants = await _repository.fetchVariants(product.id);
      if (_activeProductId != product.id) {
        return;
      }

      final filtered = PrintCatalog.filterVariants(product.id, variants);

      emit(
        state.copyWith(
          variants: filtered,
          status: PrintFlowStatus.ready,
          progressMessage: null,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      if (_activeProductId != product.id) {
        return;
      }
      _emitError(
        context: 'selectProduct',
        message: error.toString(),
        error: error,
        stackTrace: stackTrace,
        status: PrintFlowStatus.ready,
      );
    }
  }

  Future<void> selectVariant(PrintVariant variant) async {
    final product = state.selectedProduct;
    if (product == null) {
      return;
    }

    final spec = PrintCatalog.resolveSpec(product: product, variant: variant);

    emit(
      state.copyWith(
        selectedVariant: variant,
        selectedSpec: spec,
        placement: PrintPlacement.initial,
        step: PrintFlowStep.crop,
        status: PrintFlowStatus.loading,
        progressMessage: 'Preparing crop editor…',
        clearSquareArtworkBytes: true,
        clearPreviewMockupUrl: true,
        clearError: true,
      ),
    );

    await _loadSquareArtwork();
  }

  void updatePlacement(PrintPlacement placement) {
    emit(state.copyWith(placement: placement, clearError: true));
  }

  Future<void> _loadSquareArtwork() async {
    final product = state.selectedProduct;
    if (product == null) {
      return;
    }

    try {
      final bytes = await _exportService.renderRecipeToPng(
        recipe: state.recipe,
        spec: PrintCatalog.squareArtworkPreviewSpec,
        fit: PrintCatalog.fitModeFor(product.id),
        placement: PrintPlacement.initial,
      );

      if (state.step != PrintFlowStep.crop) {
        return;
      }

      emit(
        state.copyWith(
          squareArtworkBytes: bytes,
          status: PrintFlowStatus.ready,
          progressMessage: null,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _emitError(
        context: '_loadSquareArtwork',
        message: error.toString(),
        error: error,
        stackTrace: stackTrace,
        status: PrintFlowStatus.ready,
      );
    }
  }

  Future<void> confirmCrop() async {
    final product = state.selectedProduct;
    final variant = state.selectedVariant;
    final spec = state.selectedSpec;
    if (product == null || variant == null || spec == null) {
      return;
    }

    emit(
      state.copyWith(
        step: PrintFlowStep.preview,
        status: PrintFlowStatus.loading,
        progressMessage: 'Generating product preview…',
        clearPreviewMockupUrl: true,
        clearError: true,
      ),
    );

    try {
      final artworkKey = state.artworkKeyFor(spec, state.placement);

      final pngBytes = await _exportService.renderRecipeToPng(
        recipe: state.recipe,
        spec: spec,
        fit: PrintCatalog.fitModeFor(product.id),
        placement: state.placement,
      );

      if (state.step != PrintFlowStep.preview) {
        return;
      }

      emit(state.copyWith(progressMessage: 'Uploading design…'));

      final registered = await _repository.uploadDesign(
        pngBytes: pngBytes,
        recipe: state.recipe,
        spec: spec,
        localOpArtId: state.recipe['id'] as int?,
      );
      _designsByArtworkKey[artworkKey] = registered;

      if (state.step != PrintFlowStep.preview) {
        return;
      }

      final mockups = await _repository.generateMockups(
        productId: product.id,
        variantIds: [variant.id],
        designId: registered.designId,
      );

      if (state.step != PrintFlowStep.preview) {
        return;
      }

      final mockupUrl = mockups.isNotEmpty ? mockups.first.mockupUrl : null;

      emit(
        state.copyWith(
          registeredDesign: registered,
          mockups: mockups,
          previewMockupUrl: mockupUrl,
          status: PrintFlowStatus.ready,
          progressMessage: null,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _emitError(
        context: 'confirmCrop',
        message: PrintfulRepository.formatError(error),
        error: error,
        stackTrace: stackTrace,
        status: PrintFlowStatus.ready,
      );
    }
  }

  void goToCheckout() {
    if (state.registeredDesign == null || state.selectedVariant == null) {
      return;
    }

    emit(
      state.copyWith(
        step: PrintFlowStep.checkout,
        status: PrintFlowStatus.ready,
        clearError: true,
      ),
    );
  }

  void updateShippingAddress(ShippingAddress address) {
    emit(state.copyWith(shippingAddress: address, clearError: true));
  }

  Future<void> estimateShipping() async {
    final design = state.registeredDesign;
    final variant = state.selectedVariant;
    if (design == null || variant == null) {
      return;
    }

    if (state.shippingAddress.countryCode.isEmpty ||
        state.shippingAddress.zip.isEmpty) {
      _emitError(
        context: 'estimateShipping',
        message: 'Enter country and ZIP/postal code to see pricing.',
      );
      return;
    }

    emit(
      state.copyWith(
        status: PrintFlowStatus.loading,
        progressMessage: 'Calculating total…',
        clearError: true,
      ),
    );

    try {
      final estimate = await _repository.estimateOrder(
        variantId: variant.id,
        designId: design.designId,
        address: state.shippingAddress,
      );
      emit(
        state.copyWith(
          estimate: estimate,
          status: PrintFlowStatus.ready,
          progressMessage: null,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _emitError(
        context: 'estimateShipping',
        message: error.toString(),
        error: error,
        stackTrace: stackTrace,
        status: PrintFlowStatus.ready,
      );
    }
  }

  Future<void> startCheckout() async {
    final design = state.registeredDesign;
    final variant = state.selectedVariant;
    final product = state.selectedProduct;
    if (design == null || variant == null || product == null) {
      return;
    }

    final address = state.shippingAddress;
    if (address.name.isEmpty ||
        address.address1.isEmpty ||
        address.city.isEmpty ||
        address.email.isEmpty) {
      _emitError(
        context: 'startCheckout',
        message: 'Please complete all required shipping fields.',
      );
      return;
    }

    emit(
      state.copyWith(
        status: PrintFlowStatus.submitting,
        progressMessage: 'Opening secure checkout…',
        clearError: true,
      ),
    );

    try {
      final session = await _repository.createCheckoutSession(
        designId: design.designId,
        variant: variant,
        productName: '${product.title} — ${variant.size}',
        address: address,
      );
      emit(
        state.copyWith(
          checkoutSession: session,
          status: PrintFlowStatus.success,
          progressMessage: null,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _emitError(
        context: 'startCheckout',
        message: error.toString(),
        error: error,
        stackTrace: stackTrace,
        status: PrintFlowStatus.failure,
      );
    }
  }

  Future<void> completeOrder(String orderId) async {
    emit(
      state.copyWith(
        step: PrintFlowStep.confirmation,
        status: PrintFlowStatus.loading,
        progressMessage: 'Confirming order…',
        clearError: true,
      ),
    );

    try {
      final order = await _repository.fetchOrder(orderId);
      emit(
        state.copyWith(
          completedOrder: order,
          status: PrintFlowStatus.success,
          progressMessage: null,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _emitError(
        context: 'completeOrder',
        message: error.toString(),
        error: error,
        stackTrace: stackTrace,
        status: PrintFlowStatus.ready,
      );
    }
  }

  void goBack() {
    switch (state.step) {
      case PrintFlowStep.variant:
        _activeProductId = null;
        emit(
          state.copyWith(
            step: PrintFlowStep.product,
            status: PrintFlowStatus.ready,
            progressMessage: null,
            clearError: true,
          ),
        );
      case PrintFlowStep.crop:
        emit(
          state.copyWith(
            step: PrintFlowStep.variant,
            status: PrintFlowStatus.ready,
            clearSquareArtworkBytes: true,
            clearError: true,
          ),
        );
      case PrintFlowStep.preview:
        emit(
          state.copyWith(
            step: PrintFlowStep.crop,
            status: PrintFlowStatus.ready,
            clearPreviewMockupUrl: true,
            clearError: true,
          ),
        );
      case PrintFlowStep.checkout:
        emit(
          state.copyWith(
            step: PrintFlowStep.preview,
            status: PrintFlowStatus.ready,
            clearError: true,
          ),
        );
      default:
        break;
    }
  }

  void _emitError({
    required String context,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    PrintFlowStatus? status,
  }) {
    PrintFlowLog.error(
      '$context: $message',
      error: error,
      stackTrace: stackTrace,
    );
    emit(
      state.copyWith(
        status: status ?? state.status,
        errorMessage: message,
        progressMessage: null,
      ),
    );
  }
}
