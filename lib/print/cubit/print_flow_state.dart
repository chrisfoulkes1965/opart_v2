import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:opart_v2/print/models/print_catalog.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_placement.dart';
import 'package:opart_v2/print/models/print_spec.dart';

enum PrintFlowStep {
  product,
  variant,
  crop,
  preview,
  checkout,
  confirmation,
}

enum PrintFlowStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

class PrintFlowState extends Equatable {
  const PrintFlowState({
    this.step = PrintFlowStep.product,
    this.status = PrintFlowStatus.initial,
    this.recipe = const {},
    this.products = const [],
    this.variants = const [],
    this.productPreviewByProductId = const {},
    this.squareArtworkBytes,
    this.mockups = const [],
    this.previewMockupUrl,
    this.selectedProduct,
    this.selectedVariant,
    this.selectedSpec,
    this.placement = PrintPlacement.initial,
    this.registeredDesign,
    this.estimate,
    this.checkoutSession,
    this.completedOrder,
    this.shippingAddress = const ShippingAddress(
      name: '',
      address1: '',
      city: '',
      stateCode: '',
      countryCode: 'US',
      zip: '',
      email: '',
    ),
    this.errorMessage,
    this.progressMessage,
  });

  final PrintFlowStep step;
  final PrintFlowStatus status;
  final Map<String, dynamic> recipe;
  final List<PrintProduct> products;
  final List<PrintVariant> variants;
  final Map<int, Uint8List> productPreviewByProductId;
  final Uint8List? squareArtworkBytes;
  final List<PrintMockup> mockups;
  final String? previewMockupUrl;
  final PrintProduct? selectedProduct;
  final PrintVariant? selectedVariant;
  final PrintSpec? selectedSpec;
  final PrintPlacement placement;
  final RegisteredDesign? registeredDesign;
  final PrintEstimate? estimate;
  final CheckoutSession? checkoutSession;
  final PrintOrderSummary? completedOrder;
  final ShippingAddress shippingAddress;
  final String? errorMessage;
  final String? progressMessage;

  bool get hasValidRecipe => PrintCatalog.isRecipeValid(recipe);

  bool get isBusy =>
      status == PrintFlowStatus.loading || status == PrintFlowStatus.submitting;

  bool get blocksEntireScreen =>
      isBusy &&
      step != PrintFlowStep.crop &&
      step != PrintFlowStep.variant &&
      step != PrintFlowStep.preview;

  String artworkKeyFor(PrintSpec spec, [PrintPlacement? placement]) {
    final p = placement ?? this.placement;
    return '${spec.widthPx}x${spec.heightPx}_${p.cacheKey}';
  }

  PrintFlowState copyWith({
    PrintFlowStep? step,
    PrintFlowStatus? status,
    Map<String, dynamic>? recipe,
    List<PrintProduct>? products,
    List<PrintVariant>? variants,
    Map<int, Uint8List>? productPreviewByProductId,
    Uint8List? squareArtworkBytes,
    bool clearSquareArtworkBytes = false,
    List<PrintMockup>? mockups,
    String? previewMockupUrl,
    bool clearPreviewMockupUrl = false,
    PrintProduct? selectedProduct,
    PrintVariant? selectedVariant,
    PrintSpec? selectedSpec,
    PrintPlacement? placement,
    RegisteredDesign? registeredDesign,
    PrintEstimate? estimate,
    CheckoutSession? checkoutSession,
    PrintOrderSummary? completedOrder,
    ShippingAddress? shippingAddress,
    String? errorMessage,
    String? progressMessage,
    bool clearError = false,
  }) {
    return PrintFlowState(
      step: step ?? this.step,
      status: status ?? this.status,
      recipe: recipe ?? this.recipe,
      products: products ?? this.products,
      variants: variants ?? this.variants,
      productPreviewByProductId:
          productPreviewByProductId ?? this.productPreviewByProductId,
      squareArtworkBytes: clearSquareArtworkBytes
          ? null
          : squareArtworkBytes ?? this.squareArtworkBytes,
      mockups: mockups ?? this.mockups,
      previewMockupUrl: clearPreviewMockupUrl
          ? null
          : previewMockupUrl ?? this.previewMockupUrl,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedSpec: selectedSpec ?? this.selectedSpec,
      placement: placement ?? this.placement,
      registeredDesign: registeredDesign ?? this.registeredDesign,
      estimate: estimate ?? this.estimate,
      checkoutSession: checkoutSession ?? this.checkoutSession,
      completedOrder: completedOrder ?? this.completedOrder,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      progressMessage: progressMessage,
    );
  }

  @override
  List<Object?> get props => [
        step,
        status,
        recipe,
        products,
        variants,
        productPreviewByProductId,
        squareArtworkBytes,
        mockups,
        previewMockupUrl,
        selectedProduct,
        selectedVariant,
        selectedSpec,
        placement,
        registeredDesign,
        estimate,
        checkoutSession,
        completedOrder,
        shippingAddress,
        errorMessage,
        progressMessage,
      ];
}
