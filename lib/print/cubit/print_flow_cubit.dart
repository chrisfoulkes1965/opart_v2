import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/apparel_catalog.dart';
import 'package:opart_v2/print/models/device_case_catalog.dart';
import 'package:opart_v2/print/models/print_catalog.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_placement.dart';
import 'package:opart_v2/print/print_flow_log.dart';
import 'package:opart_v2/print/repositories/printful_repository.dart';
import 'package:opart_v2/print/services/print_artwork_raster_service.dart';
import 'package:opart_v2/print/services/print_export_service.dart';

class PrintFlowCubit extends Cubit<PrintFlowState> {
  factory PrintFlowCubit({
    required Map<String, dynamic> recipe,
    PrintfulRepository? repository,
    PrintArtworkRasterService? rasterService,
    PrintExportService? exportService,
  }) {
    final sharedRaster = rasterService ?? PrintArtworkRasterService();
    return PrintFlowCubit._(
      recipe: recipe,
      repository: repository ?? PrintfulRepository(),
      rasterService: sharedRaster,
      exportService:
          exportService ?? PrintExportService(rasterService: sharedRaster),
    );
  }

  PrintFlowCubit._({
    required Map<String, dynamic> recipe,
    required PrintfulRepository repository,
    required PrintArtworkRasterService rasterService,
    required PrintExportService exportService,
  })  : _repository = repository,
        _rasterService = rasterService,
        _exportService = exportService,
        super(
          PrintFlowState(
            recipe: recipe,
            status: PrintFlowStatus.loading,
            progressMessage: 'Loading products…',
          ),
        );

  final PrintfulRepository _repository;
  final PrintArtworkRasterService _rasterService;
  final PrintExportService _exportService;

  PrintArtworkRasterService get rasterService => _rasterService;

  @override
  Future<void> close() {
    _rasterService.clearCache();
    return super.close();
  }

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
      final designPreview = await _exportService.renderRecipeToPng(
        recipe: state.recipe,
        spec: PrintCatalog.squareArtworkPreviewSpec,
        placement: PrintPlacement.initial,
      );

      emit(
        state.copyWith(
          status: PrintFlowStatus.ready,
          products: products,
          designPreviewBytes: designPreview,
          productPreviewByProductId: const {},
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

  Future<void> changeRecipe(Map<String, dynamic> recipe) async {
    _activeProductId = null;
    _designsByArtworkKey.clear();
    _designFuturesByArtworkKey.clear();
    _rasterService.clearCache();

    emit(
      PrintFlowState(
        recipe: recipe,
        status: PrintFlowStatus.loading,
        progressMessage: 'Updating design…',
        products: state.products,
      ),
    );

    await initialize();
  }

  Future<Map<int, Uint8List>> _previewForProduct(PrintProduct product) async {
    final previews = Map<int, Uint8List>.from(state.productPreviewByProductId);
    if (previews.containsKey(product.id)) {
      return previews;
    }

    final spec = PrintCatalog.canonicalPreviewSpec(product.id)
        .scaledToMaxDimension(PrintCatalog.previewMaxDimensionPx);

    previews[product.id] = await _exportService.renderRecipeToPng(
      recipe: state.recipe,
      spec: spec,
      placement: PrintPlacement.initial,
    );

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
        clearPhoneCaseBrand: true,
        clearPhoneCaseVariantsByBrand: true,
        phoneCaseFinish: PhoneCaseFinish.glossy,
        clearApparelSelection: true,
        placement: PrintPlacement.initial,
        registeredDesign: null,
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
      final previews = await _previewForProduct(product);
      if (_activeProductId != product.id) {
        return;
      }

      final apparelDefaults = PrintCatalog.isApparelFront(product.id)
          ? ApparelCatalog.defaultSelection(filtered)
          : null;

      emit(
        state.copyWith(
          variants: filtered,
          productPreviewByProductId: previews,
          selectedApparelColor: apparelDefaults?.color,
          selectedApparelSize: apparelDefaults?.size,
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

  Future<void> selectPhoneCaseGroup() async {
    final product = _productForBrand(PhoneCaseBrand.iphone);
    if (product == null) {
      return;
    }

    await _enterPhoneCaseFlow(
      brand: PhoneCaseBrand.iphone,
      product: product,
    );
  }

  Future<void> selectPhoneCaseBrand(PhoneCaseBrand brand) async {
    if (state.phoneCaseBrand == brand) {
      return;
    }

    final cached = state.phoneCaseVariantsByBrand[brand];
    if (cached != null) {
      final product = _productForBrand(brand);
      if (product == null) {
        return;
      }

      emit(
        state.copyWith(
          phoneCaseBrand: brand,
          selectedProduct: product,
          variants: cached,
          status: PrintFlowStatus.ready,
          progressMessage: null,
          clearError: true,
        ),
      );
      return;
    }

    final product = _productForBrand(brand);
    if (product == null) {
      return;
    }

    await _enterPhoneCaseFlow(
      brand: brand,
      product: product,
      existingCache: state.phoneCaseVariantsByBrand,
    );
  }

  void selectPhoneCaseFinish(PhoneCaseFinish finish) {
    if (state.phoneCaseBrand == null || state.phoneCaseFinish == finish) {
      return;
    }

    emit(
      state.copyWith(
        phoneCaseFinish: finish,
        clearError: true,
      ),
    );
  }

  Future<void> selectPhoneCaseModel(String modelSize) async {
    final brand = state.phoneCaseBrand;
    if (brand == null) {
      return;
    }

    final variants = state.phoneCaseVariantsByBrand[brand] ?? state.variants;
    final variant = DeviceCaseCatalog.findVariant(
      variants: variants,
      modelSize: modelSize,
      finish: state.phoneCaseFinish,
    );
    if (variant == null) {
      return;
    }

    final product = _productForBrand(brand);
    if (product == null) {
      return;
    }

    if (state.selectedProduct?.id != product.id) {
      emit(state.copyWith(selectedProduct: product));
    }

    await selectVariant(variant);
  }

  PrintProduct? _productForBrand(PhoneCaseBrand brand) {
    for (final product in state.products) {
      if (product.id == brand.productId) {
        return product;
      }
    }
    return null;
  }

  Future<void> _enterPhoneCaseFlow({
    required PhoneCaseBrand brand,
    required PrintProduct product,
    Map<PhoneCaseBrand, List<PrintVariant>> existingCache = const {},
  }) async {
    _activeProductId = product.id;
    _designsByArtworkKey.clear();
    _designFuturesByArtworkKey.clear();

    emit(
      state.copyWith(
        selectedProduct: product,
        phoneCaseBrand: brand,
        phoneCaseFinish: PhoneCaseFinish.glossy,
        phoneCaseVariantsByBrand: existingCache,
        step: PrintFlowStep.variant,
        status: PrintFlowStatus.loading,
        progressMessage: 'Loading models…',
        variants: const [],
        selectedVariant: null,
        selectedSpec: null,
        placement: PrintPlacement.initial,
        registeredDesign: null,
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
      final previews = await _previewForProduct(product);
      if (_activeProductId != product.id) {
        return;
      }

      final cache = Map<PhoneCaseBrand, List<PrintVariant>>.from(existingCache)
        ..[brand] = filtered;

      emit(
        state.copyWith(
          variants: filtered,
          phoneCaseVariantsByBrand: cache,
          productPreviewByProductId: previews,
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
        context: 'selectPhoneCaseGroup',
        message: error.toString(),
        error: error,
        stackTrace: stackTrace,
        status: PrintFlowStatus.ready,
      );
    }
  }

  void selectApparelColor(String color) {
    final size = ApparelCatalog.firstValidSizeForColor(
      state.variants,
      color: color,
      preferredSize: state.selectedApparelSize,
    );

    emit(
      state.copyWith(
        selectedApparelColor: color,
        selectedApparelSize: size,
        clearError: true,
      ),
    );
  }

  void selectApparelSize(String size) {
    emit(
      state.copyWith(
        selectedApparelSize: size,
        clearError: true,
      ),
    );
  }

  Future<void> confirmApparelSelection() async {
    final color = state.selectedApparelColor;
    final size = state.selectedApparelSize;
    if (color == null || size == null) {
      return;
    }

    final variant = ApparelCatalog.variantFor(
      state.variants,
      color: color,
      size: size,
    );
    if (variant == null) {
      return;
    }

    await selectVariant(variant);
  }

  Future<void> selectVariant(PrintVariant variant) async {
    final product = state.selectedProduct;
    if (product == null) {
      return;
    }

    var spec = PrintCatalog.resolveSpec(product: product, variant: variant);

    emit(
      state.copyWith(
        selectedVariant: variant,
        selectedSpec: spec,
        placement: PrintPlacement.initial,
        printAreaResolved: false,
        step: PrintFlowStep.crop,
        status: PrintFlowStatus.loading,
        progressMessage: 'Loading print area…',
        clearPreviewMockupUrl: true,
        clearExportPreviewBytes: true,
        clearError: true,
      ),
    );

    try {
      final printArea = await _repository.fetchPrintArea(
        productId: product.id,
        variantId: variant.id,
        placement: PrintCatalog.mockupPlacementFor(product.id),
      );

      if (state.selectedVariant?.id != variant.id ||
          state.step != PrintFlowStep.crop) {
        return;
      }

      if (printArea.widthPx <= 0 || printArea.heightPx <= 0) {
        emit(
          state.copyWith(
            status: PrintFlowStatus.failure,
            progressMessage: null,
            printAreaResolved: false,
            errorMessage:
                'Print dimensions are unavailable for this product. Please try again.',
          ),
        );
        return;
      }

      spec = spec.withPrintArea(
        widthPx: printArea.widthPx,
        heightPx: printArea.heightPx,
        dpi: printArea.dpi,
      );

      emit(
        state.copyWith(
          selectedSpec: spec,
          placement: PrintPlacement.initial,
          printAreaResolved: true,
          status: PrintFlowStatus.ready,
          progressMessage: null,
          clearError: true,
        ),
      );
    } catch (error) {
      if (state.selectedVariant?.id != variant.id ||
          state.step != PrintFlowStep.crop) {
        return;
      }

      PrintFlowLog.info(
        'fetchPrintArea failed for ${product.id}/${variant.id}: $error',
      );

      emit(
        state.copyWith(
          status: PrintFlowStatus.failure,
          progressMessage: null,
          printAreaResolved: false,
          errorMessage:
              'Could not load print dimensions. Please check your connection and try again.',
        ),
      );
    }
  }

  Future<void> retryPrintArea() async {
    final variant = state.selectedVariant;
    if (variant == null) {
      return;
    }
    await selectVariant(variant);
  }

  void updatePlacement(PrintPlacement placement) {
    emit(state.copyWith(placement: placement, clearError: true));
  }

  Future<void> confirmCrop() async {
    final product = state.selectedProduct;
    final variant = state.selectedVariant;
    final exportSpec = state.selectedSpec;
    if (product == null || variant == null || exportSpec == null) {
      return;
    }

    if (!state.printAreaResolved) {
      emit(
        state.copyWith(
          errorMessage:
              'Print dimensions are not ready. Please retry loading the print area.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        step: PrintFlowStep.preview,
        status: PrintFlowStatus.loading,
        progressMessage: 'Generating print file…',
        clearPreviewMockupUrl: true,
        clearExportPreviewBytes: true,
        clearError: true,
      ),
    );

    try {
      if (state.step != PrintFlowStep.preview) {
        return;
      }

      final artworkKey = state.artworkKeyFor(exportSpec, state.placement);

      final pngBytes = await _exportService.renderRecipeToPng(
        recipe: state.recipe,
        spec: exportSpec,
        placement: state.placement,
      );

      if (state.step != PrintFlowStep.preview) {
        return;
      }

      emit(
        state.copyWith(
          exportPreviewBytes: pngBytes,
          progressMessage: 'Uploading design…',
        ),
      );

      final registered = await _repository.uploadDesign(
        pngBytes: pngBytes,
        recipe: state.recipe,
        spec: exportSpec,
        localOpArtId: state.recipe['id'] as int?,
      );
      _designsByArtworkKey[artworkKey] = registered;

      if (state.step != PrintFlowStep.preview) {
        return;
      }

      emit(
        state.copyWith(progressMessage: 'Generating product mockup…'),
      );

      final mockups = await _repository.generateMockups(
        productId: product.id,
        variantIds: [variant.id],
        designId: registered.designId,
        placement: PrintCatalog.mockupPlacementFor(product.id),
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

    if (state.shippingAddress.canEstimate) {
      unawaited(estimateShipping());
    }
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
    if (!address.canStartCheckout) {
      _emitError(
        context: 'startCheckout',
        message: 'Enter country and postal code to continue.',
      );
      return;
    }

    emit(
      state.copyWith(
        status: PrintFlowStatus.submitting,
        progressMessage: 'Preparing payment…',
        clearError: true,
        clearCheckoutSession: true,
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
          status: PrintFlowStatus.ready,
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
            clearPhoneCaseBrand: true,
            clearPhoneCaseVariantsByBrand: true,
            phoneCaseFinish: PhoneCaseFinish.glossy,
            clearApparelSelection: true,
            clearError: true,
          ),
        );
      case PrintFlowStep.crop:
        emit(
          state.copyWith(
            step: PrintFlowStep.variant,
            status: PrintFlowStatus.ready,
            clearError: true,
          ),
        );
      case PrintFlowStep.preview:
        emit(
          state.copyWith(
            step: PrintFlowStep.crop,
            status: PrintFlowStatus.ready,
            clearPreviewMockupUrl: true,
            clearExportPreviewBytes: true,
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
